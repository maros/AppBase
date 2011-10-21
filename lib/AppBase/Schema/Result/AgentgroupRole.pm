# ============================================================================
package AppBase::Schema::Result::AgentgroupRole;
# ============================================================================
use 5.010;

use Moose;
use namespace::autoclean;

extends 'AppBase::Schema::ResultBase';

__PACKAGE__->table("agentgroup_role");

with
    'AppBase::Schema::Field::Agentgroup',
    'AppBase::Schema::Field::Role';


#__PACKAGE__->resultset_class('AppBase::Schema::ResultSet::AgentgroupRole');

__PACKAGE__->add_unique_constraint("agentgroup_role_agentgroup_role_unique", ["agentgroup","role"]);

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
no Moose;
1;
