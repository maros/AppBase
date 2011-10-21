# ============================================================================
package AppBase::Role::Config;
# ============================================================================

use Moose::Role;

use 5.010;

has 'appbase_config_class' => (
    is              => 'ro',
    isa             => 'Str',
    lazy_build      => 1,
    builder         => '_build_appbase_config_class',
    documentation   => 'AppBase config class',
);

sub appbase_config {
    my ($self) = @_;
    
    my $config_class = $self->config_class;
    return $config_class->instance;
}

sub config {
    my ($self) = @_;
    
    return $self->appbase_config->config;
}

sub _build_appbase_config_class {
    my ($self) = @_;
    
    my $config_class;
    my @package_parts = split(/::/,(ref($self) || $self));
    
    SEARCH_CONFIG:
    foreach my $index (reverse(1..scalar(@package_parts))) {
        my $search_class = join('::',@package_parts[0..$index-1],'Config');
        my $return = eval {
            Class::MOP::load_class($search_class);
            return 1;
        };
        if ($return) {
            $config_class = $search_class;
            last SEARCH_CONFIG
        }
    }
    
    die('Could not auto-find config class')
        unless defined $config_class;
    
    return $config_class;
}

1;