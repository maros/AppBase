# ============================================================================
package AppBase::Config;
# ============================================================================

use MooseX::Singleton;
use namespace::autoclean;

use AppBase::Type;

use Clone qw(clone);
use Config::Any;
use Catalyst::Utils;
use Data::Visitor::Callback;

has 'config' => (
    is              => 'rw',
    isa             => 'HashRef',
    required        => 1,
    lazy_build      => 1,
);

has 'base_directory' => (
    is              => 'ro',
    isa             => 'Path::Class::Dir',
    coerce          => 1,
    required        => 1,
);

has 'config_directory' => (
    is              => 'ro',
    isa             => 'Path::Class::Dir',
    coerce          => 1,
    required        => 1,
);

has 'driver' => (
    is              => 'ro',
    isa             => 'HashRef',
    default         => sub { {} },
);

has 'substitutions' => (
    is              => 'ro',
    isa             => 'HashRef',
    default         => sub { {} },
);

around 'BUILDARGS' => sub {
    my $orig = shift;
    my $self = shift;
    my $params = (scalar @_ == 1 && ref $_[0] eq 'HASH' ? $_[0] : { @_ });
    
    # Overwrite with ENV
    $params->{base_directory} = Path::Class::Dir->new($ENV{'APPBASE_BASE_DIR'})
        if defined $ENV{'APPBASE_BASE_DIR'};
    
    # Search for base directory
    unless (defined $params->{base_directory}) {
        my $package_file = ref($self) || $self;
        $package_file =~ s/::/\//g;
        $package_file .= '.pm';
        $package_file = $INC{$package_file};
        if (defined $package_file) {
            my $base_dir;
            my $search_dir = Path::Class::File->new($package_file)->resolve->dir;
            SEARCH_BASE:
            while ($search_dir->stringify ne $search_dir->parent()->stringify) {
                foreach my $child ($search_dir->children) {
                    next
                        unless $child->is_dir;
                    if (lc($child->basename) eq 'lib') {
                        $base_dir = $search_dir;
                        last SEARCH_BASE;
                    }
                }
                $search_dir = $search_dir->parent();
            }
            if (defined $base_dir) {
                $params->{base_directory} = $base_dir;
            }
        }
    }
    
    # Overwrite with ENV
    $params->{config_directory} = Path::Class::Dir->new($ENV{'APPBASE_CONFIG_DIR'})
        if defined $ENV{'APPBASE_CONFIG_DIR'};
    
    $params->{config_directory} ||= $params->{base_directory}->subdir('config')
        if defined $params->{base_directory};
    
    $self->$orig($params);
};

sub _build_config {
    my ($self) = @_;

    my $extension_re = join('|',map { "\Q$_\E" } @{ Config::Any->extensions });
    
    my @files;
    $self->config_directory->recurse( callback => sub {
        my ($element) = @_;
        return 1
            if $element->is_dir;
        if ($element->basename =~ m/\.($extension_re)$/i ) {
            if ($element->basename =~ m/\blocal\b/) {
                push (@files,$element->stringify);
            } else {
                unshift (@files,$element->stringify);
            } 
        }
    } );
    
    die('No config files fond')
        unless scalar(@files) > 0;
    
    @files = sort { $a cmp $b } @files;
    
    my $configs = Config::Any->load_files({   
        files       => \@files,
        filter      => \&_fix_syntax,
        use_ext     => 1,
        driver_args => $self->driver,
    });
    
    my $final_config = {};
    foreach my $config (@$configs) {
        my ($filename, $data) = %$config;
        $final_config =  Catalyst::Utils::merge_hashes($final_config,$data);
    }
    
    my $visitor = Data::Visitor::Callback->new(
        plain_value => sub {
            return unless defined $_;
            $self->config_substitutions( $_ );
        }
    );
    $visitor->visit( $final_config );
    
    return $final_config;
}

sub config_substitutions {
    my ($self,$data) = @_;
    
    my $substitutions = $self->{ substitutions } || {};
    
    $substitutions->{ HOME }    ||= sub { shift->base_directory; };
    $substitutions->{ ENV }    ||=
        sub {
            my ( $self, $value ) = @_;
            if (! defined($ENV{$value})) {
                die( "Missing environment variable: $value" );
            } else {
                return $ENV{ $value };
            }
        };
    $substitutions->{ path_to } ||= sub { shift->base_directory->dir(@_) };
    $substitutions->{ literal } ||= sub { return $_[ 1 ]; };
    my $subsre = join( '|', keys %$substitutions );

    for ( @_ ) {
        s{__($subsre)(?:\((.+?)\))?__}{ $substitutions->{ $1 }->( $self, $2 ? split( /,/, $2 ) : () ) }eg;
    }
}

sub _fix_syntax {
    my $config     = shift;
    
    my @components = (
        map +{
            prefix => $_ eq 'Component' ? '' : $_ . '::',
            values => delete $config->{ lc $_ } || delete $config->{ $_ }
        },
        grep { ref $config->{ lc $_ } || ref $config->{ $_ } }
            qw( Component Model M View V Controller C Plugin )
    );

    foreach my $comp ( @components ) {
        my $prefix = $comp->{ prefix };
        foreach my $element ( keys %{ $comp->{ values } } ) {
            $config->{ "$prefix$element" } = $comp->{ values }->{ $element };
        }
    }
}

sub get {
    my ($self,$key) = @_;
    
    my $config = $self->config;
    if (defined $key) {
        if (exists $config->{$key}) {
            return clone($config->{$key});
        } else {
            return {};
        }
    } else {
        return clone($config);
    }
}

__PACKAGE__->meta->make_immutable;
1;