# -*- perl -*-

use Test::Most tests => 4;

use_ok('AppBase::Config'); 
    
my $config = AppBase::Config->initialize();

isa_ok($config,'AppBase::Config');
like($config->config_directory->stringify,qr/\/config$/,'Base directory ok');

AppBase::Config->_clear_instance;

my $config2 = AppBase::Config->initialize( config_directory => 't/config/testdata' );

my $config2_data = $config2->config;

cmp_deeply($config2_data,{
    'test1' => 'Test1',
    'test2' => {
        'key1' => 'value1',
        'key2' => 'value2_alt',
        'key3' => 'value3'
    }
},'Config loaded ok');

