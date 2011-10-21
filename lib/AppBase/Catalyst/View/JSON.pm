package AppBase::Catalyst::View::JSON;

use 5.010;
use Moose;
use namespace::autoclean;

extends 'Catalyst::View::JSON';

sub encode_json {
    my($self, $c, $data) = @_;

    my $encoder = $c->debug ? 
        JSON::XS->new->utf8->pretty->allow_nonref :
        JSON::XS->new->utf8->allow_nonref;

    $encoder->encode($data);
}

no Moose;
1;
