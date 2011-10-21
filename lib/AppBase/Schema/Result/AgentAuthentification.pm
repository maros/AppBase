# ============================================================================
package AppBase::Schema::Result::AgentAuthentification;
# ============================================================================
use 5.010;

use Moose;
use namespace::autoclean;

extends 'AppBase::Schema::ResultBase';

__PACKAGE__->table("agent_authentication");

with
    'AppBase::Schema::Field::Agent',
    'AppBase::Schema::Field::Deleted',
    'AppBase::Schema::Field::Active',
    'AppBase::Schema::Field::VariableStorage';


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

#__PACKAGE__->resultset_class('AppBase::Schema::ResultSet::AgentAuthentification');
__PACKAGE__->add_unique_constraint("agent_agentgroup_agent_type_unique", ["agent","type"]);

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
no Moose;
1;
