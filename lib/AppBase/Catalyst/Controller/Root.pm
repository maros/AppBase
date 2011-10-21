# ============================================================================
package AppBase::Catalyst::Controller::Root;
# ============================================================================

use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

__PACKAGE__->config(namespace => '');

sub index : Local {
    my ( $self, $c ) = @_;
    $c->res->body('ok');
}

sub default :Path {
    my ( $self, $c, @args ) = @_;
    AppBase::X::Catalyst::Notfound->throw();
}

sub end : ActionClass('RenderView') {
    my( $self, $c ) = @_;
    
}
__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
1;
