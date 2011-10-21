# ============================================================================
package AppBase::Schema::Result::AgentAgentgroup;
# ============================================================================
use 5.010;

use Moose;
use namespace::autoclean;

extends 'AppBase::Schema::ResultBase';

__PACKAGE__->table("agent_agentgroup");

with
    'AppBase::Schema::Field::Agent',
    'AppBase::Schema::Field::Agentgroup';


#__PACKAGE__->resultset_class('AppBase::Schema::ResultSet::AgentAgentgroup');
__PACKAGE__->add_unique_constraint("agent_agentgroup_agent_agentgroup_unique", ["agent","agentgroup"]);

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
no Moose;
1;
