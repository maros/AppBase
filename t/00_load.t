# -*- perl -*-

# t/00_load.t - check module loading and create testing directory

use Test::Most tests => 1;

BEGIN { 
    use_ok('TEMPLATE-PACKAGE'); 
}