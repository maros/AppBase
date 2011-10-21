#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;

BEGIN {
    use FindBin;
    use lib "$FindBin::Bin/../lib";
};

use Plack::Builder;
use AppBase::Catalyst;

builder {
    if ($ENV{DEBUG} || $ENV{CATALYST_DEBUG}) {
        enable 'Debug', panels => [qw(DBITrace Memory Timer Environment)];
    }
    
    my $static_server = builder {
        enable "Plack::Middleware::Static::Minifier", 
            path => sub { 1 },
            root => "$FindBin::Bin/../root/static/";
    };
    
    mount '/static' => $static_server;
    mount '/'       => AppBase::Catalyst->psgi_app(@_);
};



