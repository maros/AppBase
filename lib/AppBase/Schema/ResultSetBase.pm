# ============================================================================
package AppBase::Schema::ResultSetBase;
# ============================================================================
use 5.010;

use Moose;
use MooseX::NonMoose;
extends qw(DBIx::Class::ResultSet);
use namespace::autoclean;

__PACKAGE__->meta->make_immutable;
1;