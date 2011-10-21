# ============================================================================
package AppBase::Schema::Field::Role;
# ============================================================================
use 5.010;

use Moose::Role;
use DBIx::Class::MooseColumns;
use Lingua::EN::Inflect qw(PL);

our $RESULT_CLASS = 'AppBase::Schema::Result::Role';
our $FIELDNAME = 'role';

before 'finalize' => sub {
    my ($self) = @_;
    
    $self->register_relation({
        package => $self,
        type    => 'belongs_to',
        params  => [$FIELDNAME,$RESULT_CLASS,{ "foreign.id" => "self.$FIELDNAME" }],
    });
    
    $self->register_relation({
        package => $RESULT_CLASS,
        type    => 'has_many',
        params  => [PL($self->table),$self,{ "foreign.$FIELDNAME" => "self.id" }],
    });
};

has $FIELDNAME => (
    isa => $RESULT_CLASS,
    is  => 'rw',
    required => 1,
    add_column => {
        data_type => "integer",
        default_value => undef,
        is_foreign_key => 1,
        is_nullable => 0,
        size => 4,
    },
);

no Moose::Role;

1;