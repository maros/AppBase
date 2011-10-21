# ============================================================================
package AppBase::Schema::Result::Person;
# ============================================================================
use 5.010;

use Moose;
use namespace::autoclean;

extends 'AppBase::Schema::ResultBase';

__PACKAGE__->table('person');

with
    'AppBase::Schema::Field::VariableStorage';

has [qw(firstname lastname title)] => (
    isa => 'Str',
    is  => 'rw',
    add_column => {
        data_type => "character varying",
        default_value => undef,
        is_nullable => 1,
        size => undef,
    },
);

has 'birthday' => (
    isa => 'DateTime',
    is  => 'rw',
    add_column => {
        data_type => "date",
        default_value => undef,
        is_nullable => 1,
        size => undef,
    },
);

has 'gender' => (
    isa => 'AppBase::Type::Gender',
    is  => 'rw',
    add_column => {
        data_type => "appbase.gender",
        default_value => undef,
        is_nullable => 1,
        size => 4,
    },
);

has [qw(organization address_line1 address_line2 address_city address_state address_zip)] => (
    isa => 'Str',
    is  => 'rw',
    add_column => {
        data_type => "character varying",
        default_value => undef,
        is_nullable => 1,
        size => undef,
    },
);

has 'address_country' => (
    isa => 'CatalystX::I18N::Type::Territory',
    is  => 'rw',
    add_column => {
        data_type => "character",
        default_value => undef,
        is_nullable => 1,
        size => 2,
    },
);


#__PACKAGE__->resultset_class('AppBase::Schema::ResultSet::Agent');

__PACKAGE__->has_one(
    agent => 'AppBase::Schema::Result::Agent',
    { 'foreign.person' => 'self.id' },
);

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
no Moose;
1;
