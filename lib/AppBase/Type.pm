# ============================================================================
package AppBase::Type;
# ============================================================================

use strict;
use warnings;

use Moose::Util::TypeConstraints;

use CatalystX::I18N::TypeConstraints;
use MooseX::Types::Path::Class;

use DateTime::TimeZone;

subtype 'AppBase::Type::Config'
    => as 'Object'
    => where { $_->isa('AppBase::Config') }
    => message { sprintf("'%s' is not a AppBase::Config object",$_) };

coerce 'AppBase::Type::Config'
    => from 'Str'
    => via {
        Class::MOP::load_class($_);
        return $_->new();
    };

subtype 'AppBase::Type::Gender'
    => as enum(['m','f']);

#subtype 'AppBase::Type::DirList'
#    => as 'ArrayRef[Path::Class::Dir]';

subtype 'AppBase::Type::FileList'
    => as 'ArrayRef[Path::Class::File]';

#coerce 'AppBase::Type::DirList'
#    => from 'Str'
#    => via { [ Path::Class::Dir->new($_) ] }
#    => from 'ArrayRef[Str]'
#    => via { [ map { Path::Class::Dir->new($_) } @$_ ] }
#    => from 'Path::Class::Dir'
#    => via { [ $_ ] };

coerce 'AppBase::Type::FileList'
    => from 'Str'
    => via { [ Path::Class::File->new($_) ] }
    => from 'ArrayRef[Str]'
    => via { [ map { Path::Class::File->new($_) } @$_ ] }
    => from 'Path::Class::File'
    => via { [ $_ ] };

1;