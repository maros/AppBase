# ============================================================================
package AppBase::Schema::Result::AgentContact;
# ============================================================================
use 5.010;

use Moose;
use namespace::autoclean;

extends 'AppBase::Schema::ResultBase';

__PACKAGE__->table("agent_contact");

with
    'AppBase::Schema::Field::Agent';


has ['type','contact'] => (
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

has 'primary' => (
    isa => 'Bool',
    is  => 'rw',
    required => 1,
    default => 0,
    add_column => {
        data_type => "Boolean",
        default_value => 0,
        is_nullable => 0,
        size => undef,
    },
);

has 'memo' => (
    isa => 'Str',
    is  => 'rw',
    add_column => {
        data_type => "character varying",
        default_value => undef,
        is_nullable => 1,
        size => undef,
    },
);

#__PACKAGE__->resultset_class('AppBase::Schema::ResultSet::AgentContact');

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
no Moose;
1;
