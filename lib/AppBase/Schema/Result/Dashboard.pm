# ============================================================================
package AppBase::Schema::Result::Dashboard;
# ============================================================================
use 5.010;

use Moose;
use namespace::autoclean;

extends 'AppBase::Schema::ResultBase';

__PACKAGE__->table("dashboard");

with
    'AppBase::Schema::Field::Agent';


has 'name' => (
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

has 'memo' => (
    isa => 'Str',
    is  => 'rw',
    required => 0,
    add_column => {
        data_type => "character varying",
        default_value => undef,
        is_nullable => 1,
        size => undef,
    },
);

has 'public' => (
    isa => 'Bool',
    is  => 'rw',
    required => 1,
    default => 0,
    add_column => {
        data_type => "boolean",
        default_value => "false",
        is_nullable => 0,
        size => 1,
    },
);

#__PACKAGE__->resultset_class('AppBase::Schema::ResultSet::Dashboard');

__PACKAGE__->has_many(
    'dashboard_widgets',
    'AppBase::Schema::Result::DashboardWidget',
    { "foreign.dashboard" => "self.id" },
);


__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
no Moose;
1;
