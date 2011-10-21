# ============================================================================
package AppBase::Schema::Result::Role;
# ============================================================================
use 5.010;

use Moose;
use namespace::autoclean;

extends 'AppBase::Schema::ResultBase';

__PACKAGE__->table("role");

with
    'AppBase::Schema::Field::Active';


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

#__PACKAGE__->resultset_class('AppBase::Schema::ResultSet::Role');

__PACKAGE__->add_unique_constraint("role_name_unique", ["name"]);

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
no Moose;
1;
