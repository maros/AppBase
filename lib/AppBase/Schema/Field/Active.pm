# ============================================================================
package AppBase::Schema::Field::Active;
# ============================================================================
use 5.010;

use Moose::Role;
use DBIx::Class::MooseColumns;

has 'active' => (
    isa => 'Bool',
    is  => 'rw',
    default => 1,
    required => 1,
    add_column => {
        data_type => "boolean",
        default_value => 'true',
        is_nullable => 0,
        size => 1,
    },
);

no Moose::Role;
1;