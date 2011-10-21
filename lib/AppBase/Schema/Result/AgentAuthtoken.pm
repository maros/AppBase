# ============================================================================
package AppBase::Schema::Result::AgentAuthtoken;
# ============================================================================
use 5.010;

use Moose;
use namespace::autoclean;

extends 'AppBase::Schema::ResultBase';

__PACKAGE__->table("agent_authtoken");

with
    'AppBase::Schema::Field::Agent',
    'AppBase::Schema::Field::Active';


has 'type' => (
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

has 'token' => (
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

has 'valid_to' => (
    isa => 'Maybe[DateTime]',
    is  => 'rw',
    add_column => {
        data_type => "date",
        default_value => undef,
        is_nullable => 1,
        size => 4,
    },
);

has 'onetime' => (
    isa => 'Bool',
    is  => 'rw',
    default => 0,
    required => 0,
    add_column => {
        data_type => "boolean",
        default_value => "false",
        is_nullable => 0,
        size => 1,
    },
);


#__PACKAGE__->resultset_class('AppBase::Schema::ResultSet::AgentAuthtoken');
__PACKAGE__->add_unique_constraint("agent_authtoken_token_unique", ["token"]);


__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
no Moose;
1;

1;
