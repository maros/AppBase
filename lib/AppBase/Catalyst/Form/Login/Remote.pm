# ============================================================================
package AppBase::Catalyst::Form::Login::Remote;
# ============================================================================

use 5.010;

use Moose;

use HTML::FormHandler::Moose;
use namespace::autoclean;

extends 'HTML::FormHandler';

has_field 'username' => ( type => 'Text', required => 1 );
has_field 'service' => ( type => 'Radio', required => 1, options => ['Google','Yahoo','Twitter','OpenID'] );
has_field 'submit' => ( type => 'Submit', value => 'Login' );

__PACKAGE__->meta->make_immutable();
1;
