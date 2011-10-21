# ============================================================================
package AppBase::Catalyst;
# ============================================================================

use Moose;
use namespace::autoclean;

use AppBase;
use Catalyst::Runtime 5.90;
use Catalyst qw/
    Unicode::Encoding
    Static::Simple
    StackTrace
    
    +AppBase::Role::DB
    +AppBase::Role::Catalyst::Config
    +AppBase::Role::Catalyst::Exception
    
    +CatalystX::I18N::Role::All
    
    Session
    Session::State::Cookie
    +AppBase::Role::Catalyst::SessionStore
/;

extends 'Catalyst';

#    +AppBase::Catalyst::Session::Store::AppBase
#    Authentication
#    Authentication::Credential::Password
#    Authorization::Roles
#    Authorization::ACL

__PACKAGE__->setup;

1;

