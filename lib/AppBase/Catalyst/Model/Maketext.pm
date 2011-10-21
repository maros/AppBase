# ============================================================================
package AppBase::Catalyst::Model::Maketext;
# ============================================================================

use Moose;
extends qw(CatalystX::I18N::Model::Maketext);

__PACKAGE__->meta->make_immutable;
no Moose;
1;