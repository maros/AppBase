# ============================================================================
package AppBase::Catalyst::Controller::Login;
# ============================================================================

use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

sub login : Path:Path('/login') Args(0) {
    my ( $self, $c ) = @_;
    # Get enabled login forms/methods
    return 0;
}

sub logout : Path:Path('/logout') Args(0) {
    my ( $self, $c ) = @_;
    $c->logout;
    return 0;
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
1;
