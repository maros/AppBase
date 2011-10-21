# ============================================================================
package AppBase::Schema::Result::Session;
# ============================================================================
use 5.010;

use Moose;
use namespace::autoclean;

extends 'AppBase::Schema::ResultBase';

__PACKAGE__->table("session");

with
    'AppBase::Schema::Field::Agent',
    'AppBase::Schema::Field::VariableStorage';


has 'agent_authentication' => (
    isa => 'AppBase::Schema::Result::AgentAuthentification',
    is  => 'rw',
    required => 1,
    add_column => {
        data_type => "integer",
        default_value => undef,
        is_nullable => 0,
        size => 4,
    },
);

has ['sessionid','client_device','client_address'] => (
    isa => 'Str',
    is  => 'rw',
    required => 1,
    add_column => {
        data_type => "character varying",
        default_value => undef,
        is_nullable => 0,
        size => undef,
    },
);

has 'start_timestamp' => (
    isa => 'DateTime',
    is  => 'rw',
    required => 1,
    default => sub { DateTime->new( time_zone => 'floating' ) },
    add_column => {
        data_type => "timestamp without time zone",
        default_value => "now()",
        is_nullable => 0,
        size => 8,
    },
);

has 'end_timestamp' => (
    isa => 'DateTime',
    is  => 'rw',
    add_column => {
        data_type => "timestamp without time zone",
        default_value => undef,
        is_nullable => 1,
        size => 8,
    },
);
  
#__PACKAGE__->resultset_class('AppBase::Schema::ResultSet::Session');

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
no Moose;
1;
