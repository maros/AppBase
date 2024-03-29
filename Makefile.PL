# Load the Module::Install bundled in ./inc/
use strict;
use inc::Module::Install 0.92;

my $from = 'lib/AppBase.pm';

# Define metadata
name            'AppBase';
all_from        $from;
readme_from     $from;

perl_version    '5.010';

# Specific dependencies
requires        'Moose'                     => '0.94';
requires        'version'                   => 0;
requires        'parent'                    => 0;

requires        'Catalyst::Runtime'         => '0.94';
requires        'DBIx::Class::MooseColumns' => 0;
requires        'CatalystX::I18N'           => 0;
requires        'MooseX::Singleton'         => 0;

build_requires  'Test::Most'                => 0;

author_requires 'Test::Pod'                 => '1.14';
author_requires 'Test::Pod::Coverage'       => '1.04';
author_requires 'Test::Perl::Critic'        => 0;
author_requires 'Module::Install::ReadmeFromPod'        => 0;

repository 'git://github.com/maros/appbase.git';

WriteAll;