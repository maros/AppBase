# ============================================================================
package AppBase::Schema::Result::Lock;
# ============================================================================
use 5.010;

use Moose;
use namespace::autoclean;

extends 'AppBase::Schema::ResultBase';

__PACKAGE__->table("lock");

has 'session' => (
    isa => 'AppBase::Schema::Result:Session',
    is  => 'rw',
    required => 1,
    add_column => {
        data_type => "integer",
        default_value => undef,
        is_nullable => 0,
        size => 4,
    },
);

has 'class' => (
    isa => 'Str',
    is  => 'rw',
    required => 1,
    add_column => {
        data_type => "Str",
        default_value => undef,
        is_nullable => 0,
        size => undef,
    },
);


has 'element' => (
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

has 'maxage' => (
    isa => 'DateTime',
    is  => 'rw',
    add_column => {
        data_type => "timestamp without time zone",
        default_value => undef,
        is_nullable => 1,
        size => 8,
    },
);

#__PACKAGE__->resultset_class('AppBase::Schema::ResultSet::Lock');

__PACKAGE__->belongs_to(
    'session',
    'AppBase::Schema::Result::Session',
    { "foreign.id" => "self.session" },
);

__PACKAGE__->add_unique_constraint("lock_class_element_unique", ["class","element"]);

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
no Moose;
1;
