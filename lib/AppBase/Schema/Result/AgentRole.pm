# ============================================================================
package AppBase::Schema::Result::AgentRole;
# ============================================================================
use 5.010;

use Moose;
use namespace::autoclean;

extends 'AppBase::Schema::ResultBase';

__PACKAGE__->table("agent_role");

with
    'AppBase::Schema::Field::Agent',
    'AppBase::Schema::Field::Role';


#__PACKAGE__->resultset_class('AppBase::Schema::ResultSet::AgentRole');

__PACKAGE__->add_unique_constraint("agent_role_agent_role_unique", ["agent","role"]);

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
no Moose;
1;
