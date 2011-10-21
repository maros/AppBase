# ============================================================================
package AppBase::Role::DB;
# ============================================================================

use Moose::Role;
use 5.010;
use MooseX::Getopt::Meta::Attribute::Trait::NoGetopt;
use Scalar::Util qw(blessed);

# Global connection cache
our %DB;

sub db {
    my ($self,$connection) = @_;
    
    $connection //= 'main';
    
    return $DB{$connection}
        if defined $DB{$connection}
        && $DB{$connection}->isa('DBIx::Class::Schema');
    
    return $self->_build_db($connection);
}

sub dbh { 
    my $self = shift;
    return $self->db->storage->dbh;
}

sub _build_db {
    my ($self,$connection) = @_;
    
    warn $self->config;
    
    # Get config
    my $config = $self->config->get('Database');
    
    return
        unless defined $config->{$connection};
    my $dbconfig = $config->{$connection};
    
    # Get database credentials & DSN
    my $user = $ENV{DBUSER} || $dbconfig->{user};
    my $password = $ENV{DBPASSWORD} || $dbconfig->{password};
    my $dsn = $ENV{DBDSN} || $dbconfig->{dsn};
    
    # On connect actions
    my $connectactions = $dbconfig->{connectactions} || [];
    
    # Get DBI & DBIC attributes
    my $attributes = $dbconfig->{attributes} || {};
    $attributes->{AutoCommit} //= 1;
    $attributes->{RaiseError} //= 1;
    #$attributes->{HandleError} //= sub {};
    $attributes->{auto_savepoint} //= 1;
    $attributes->{on_connect_call} ||= [];
    
    # Driver specific settings
    my (undef, $driver, undef, undef, undef) = DBI->parse_dsn($dsn);
    given ($driver) {
        when('Pg') {
            push (@$connectactions,"SET CLIENT_ENCODING TO 'UTF8'");
            $attributes->{pg_enable_utf8} //= 1;
        }
    }
    
    # On connect call handler
    push(@{$attributes->{on_connect_call}},
        sub {
            my ($storage) = shift;
            $storage->dbh_do(sub {
                my ($storage, $dbh) = @_;
                foreach (@$connectactions) {
                    $dbh->do($_);
                }
            });
        }
    );
    
    my $schemaclass = $dbconfig->{schema};
    
    # Connect
    my $schema = $schemaclass->connect(
        $dsn,
        $user,
        $password,
        $attributes
    );
    
#    if (defined $connectparams->{country}
#        && $connectparams->{country} =~ m/^[A-Z]{2}$/){
#        my $country = $connectparams->{country};
#        my $country_config = countries($country);
#        my $language = $country_config->{languages}[0];
#        my $locale = $language.'_'.$country;
#        $schema->country($country);
#        $schema->lang($language);
#        $schema->current_locale($locale);
#        $schema->timezone($country_config->{timezone});
#        $schema->l10ndate(DateTime::Locale->load($locale));
#        $schema->l10strpdate(new DateTime::Format::Strptime(
#            pattern   => locales($locale)->{date}{strftime},
#            locale    => $schema->l10ndate,
#            time_zone => $schema->timezone,
#        ) );
#    }
    
    # Store connection
    $DB{$connection} = $schema;
    
    return $schema;
}

sub END {
    foreach my $schema (values %DB) {
        next
            unless defined $schema;
        $schema->storage->disconnect;
    }
}

1;
