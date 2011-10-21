# ============================================================================
package AppBase::Catalyst::Form::Login::Basic;
# ============================================================================

use 5.010;

use Moose;

use HTML::FormHandler::Moose;
use namespace::autoclean;

extends 'HTML::FormHandler';

has_field 'username' => ( type => 'Text', required => 1 );
has_field 'password' => ( type => 'Password', required => 1 );
has_field 'submit' => ( type => 'Submit', value => 'Login' );

__PACKAGE__->meta->make_immutable();
1;
