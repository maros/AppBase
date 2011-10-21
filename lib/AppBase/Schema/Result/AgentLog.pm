# ============================================================================
package AppBase::Schema::Result::AgentLog;
# ============================================================================
use 5.010;

use Moose;
use namespace::autoclean;

extends 'AppBase::Schema::ResultBase';

__PACKAGE__->table("agent_log");

with
    'AppBase::Schema::Field::Agent',
    'AppBase::Schema::Field::VariableStorage';

has ['type','message'] => (
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

#__PACKAGE__->resultset_class('AppBase::Schema::ResultSet::AgentLog');

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
no Moose;
1;
