# ============================================================================
package AppBase::Schema::ResultSet::Role;
# ============================================================================
use 5.010;

use Moose;
use namespace::autoclean;
extends qw(AppBase::Schema::ResultSetBase);

__PACKAGE__->meta->make_immutable;
no Moose;
1;