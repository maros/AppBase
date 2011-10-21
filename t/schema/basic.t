# -*- perl -*-

use Test::Most tests => 3;

use_ok('AppBase::Schema'); 
    
my $schema = AppBase::Schema->connect("dbi:SQLite:dbname=t/test.db","","",{ RaiseError => 1 });
ok($schema->source('Agent')->has_column('username'),'Has username');
ok($schema->source('Agent')->has_column('active'),'Has active');
