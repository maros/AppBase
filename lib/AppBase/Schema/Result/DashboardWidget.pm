# ============================================================================
package AppBase::Schema::Result::DashboardWidget;
# ============================================================================
use 5.010;

use Moose;
use namespace::autoclean;

extends 'AppBase::Schema::ResultBase';

__PACKAGE__->table("dashboard_widget");

with
    'AppBase::Schema::Field::VariableStorage';

has 'dashboard' => (
    isa => 'AppBase::Schema::Result::Dashboard',
    is  => 'rw',
    required => 1,
    add_column => {
        data_type => "integer",
        default_value => undef,
        is_nullable => 0,
        size => 4,
    },
);

has ['position_block','type'] => (
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

has 'position_index' => (
    isa => 'Int',
    is  => 'rw',
    required => 1,
    add_column => {
        data_type => "integer",
        default_value => undef,
        is_nullable => 0,
        size => 4,
    },
);

has 'refresh' => (
    isa => 'Int',
    is  => 'rw',
    required => 0,
    add_column => {
        data_type => "integer",
        default_value => undef,
        is_nullable => 1,
        size => 4,
    },
);

#__PACKAGE__->resultset_class('AppBase::Schema::ResultSet::DashboardWidget');

__PACKAGE__->belongs_to(
    'dashboard',
    'AppBase::Schema::Result::Dashboard',
    { "foreign.id" => "self.dashboard" },
);

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
no Moose;
1;
