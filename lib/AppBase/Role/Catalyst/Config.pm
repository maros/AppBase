# ============================================================================
package AppBase::Role::Catalyst::Config;
# ============================================================================

use Moose::Role;
requires qw(config);

with 'Catalyst::ClassData';

sub appbase_config {
    my ($c) = @_;
    
    return $c->appbase_config_class->instance;
}

around 'setup' => sub {
    my $orig = shift;
    my $class = shift;
    
    my $config_class;
    my @package_parts = split(/::/,(ref($class) || $class));
    
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
    
    # Create appbase_config_class accessor
    $class->mk_classdata('appbase_config_class');
    $class->appbase_config_class($config_class);
    
    my $appbase_config = $config_class->instance->config;
    
    my $catalyst_config = {
        %{$appbase_config->{Catalyst}}
    };
    
    # Shallow config
    foreach my $key (keys %{$appbase_config}) {
        next
            if ($key eq 'Catalyst');
        $catalyst_config->{$key} = $appbase_config->{$key};
    }
    $class->config($catalyst_config);
    
    $class->$orig(@_);
};

no Moose::Role;
1;