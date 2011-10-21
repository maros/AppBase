# ============================================================================
package AppBase::Schema::Field::Deleted;
# ============================================================================
use 5.010;

use Moose::Role;
use DBIx::Class::MooseColumns;

has 'deleted' => (
    isa => 'Bool',
    is  => 'rw',
    default => 0,
    required => 1,
    add_column => {
        data_type => "boolean",
        default_value => 'false',
        is_nullable => 0,
        size => 1,
    },
);

no Moose::Role;

1;