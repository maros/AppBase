package AppBase::Meta::Trait::Class::DBIC;

use Moose::Role;
use Moose::Util;

before 'make_immutable' => sub {
    my $self = shift;
    my $name = $self->name;
    
    $name->finalize()
        if $name->can('finalize');
};

no Moose::Role;

1;