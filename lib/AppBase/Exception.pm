# ============================================================================
package AppBase::Exception;
# ============================================================================

use strict;
use warnings;
use 5.010;

#BEGIN {
#    no warnings 'once';
#    $Catalyst::Exception::CATALYST_EXCEPTION_CLASS = 'AppBase::X::Catalyst';
#}

use Exception::Class
    (
        'AppBase::X' => {},
        'AppBase::X::Catalyst' => {
            isa            => 'AppBase::X',
            description    => 'Abstract Catalyst exception class',
        },
        'AppBase::X::Catalyst::Notfound' => {
            isa            => 'AppBase::X::Catalyst',
            description    => '404 - File Not Found',
        },
        'AppBase::X::Catalyst::Forbidden' => {
            isa            => 'AppBase::X::Catalyst',
            description    => '403 - Access Denied',
        },
        'AppBase::X::Catalyst::Unauthorized' => {
            isa            => 'AppBase::X::Catalyst',
            description    => '401 - Unauthorized',
        },
    );

## Translate message -> error
#sub AppBase::X::Catalyst::throw {
#    my $proto = shift;
#
#    $proto->rethrow if ref $proto;
#    
#    my %params;
#    if (scalar @_ == 1) {
#        $params{error} = $_[0];
#    } else {
#        %params = @_;
#    }
#
#    $params{error} ||= $params{message};
#    delete $params{message};
#
#    die $proto->new(%params);
#}

1;