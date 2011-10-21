# ============================================================================
package AppBase::Schema::Result::Agent;
# ============================================================================
use 5.010;

use Moose;
use namespace::autoclean;

extends 'AppBase::Schema::ResultBase';

__PACKAGE__->table('agent');

with
    'AppBase::Schema::Field::Deleted',
    'AppBase::Schema::Field::Active',
    'AppBase::Schema::Field::VariableStorage';


has 'username' => (
    isa => 'Str',
    is  => 'rw',
    required => 1,
    add_column => {
        data_type => "character varying",
        default_value => undef,
        is_nullable => 0,
        size => 1,
    },
);

has 'systemuser' => (
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

has 'person' => (
    isa => 'AppBase::Schema::Result::Person',
    is  => 'rw',
    required => 0,
    add_column => {
        data_type => "integer",
        default_value => undef,
        is_nullable => 1,
        size => 4,
    },
);

has 'timezone' => (
    isa => 'CatalystX::I18N::Type::TimeZone',
    is  => 'rw',
    add_column => {
        data_type => "character varying",
        default_value => undef,
        is_nullable => 1,
        size => undef,
    },
);

has 'language' => (
    isa => 'CatalystX::I18N::Type::Language',
    is  => 'rw',
    add_column => {
        data_type => "character varying",
        default_value => undef,
        is_nullable => 1,
        size => undef,
    },
);


#__PACKAGE__->resultset_class('AppBase::Schema::ResultSet::Agent');
__PACKAGE__->add_unique_constraint("agent_username_unique", ["username"]);

__PACKAGE__->might_have(
    person => 'AppBase::Schema::Result::Person',
    { 'foreign.id' => 'self.person' },
  );

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
no Moose;
1;
