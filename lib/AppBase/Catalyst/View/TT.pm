# ============================================================================
package AppBase::Catalyst::View::TT;
# ============================================================================

use Moose;
use MooseX::NonMoose;
extends qw(Catalyst::View::TT::ForceUTF8);
with qw(CatalystX::I18N::TraitFor::ViewTT);

use JSON qw();

around 'BUILDARGS' => sub {
    my $orig  = shift;
    my ( $class,$app,$arguments ) = @_;
    
    my $config = {
        STRICT_CONTENT_TYPE => 1,
        DEFAULT_ENCODING    => 'utf-8',
        TEMPLATE_EXTENSION  => '.tt',
        PRE_PROCESS         => 'config',
        WRAPPER             => 'wrapper.tt',
        #ERROR               => 'errors/servererror.tt',
        TIMER               => '0',
        render_die          => 1,
        %{ $class->config },
        %{ $arguments },
    };
    
    $config->{FILTERS} ||= {};
    $config->{FILTERS}{js}       = sub {
        my $string = shift;
        $string =~ s/(['"\\\/])/\\$1/gs;
        $string =~ s/\n/\\n/gs;
        return $string;
    };
    
    # set include_paths
    my $include_path = $config->{INCLUDE_PATH} || [];
    push( @$include_path, $app->path_to('/root/templates/') );
    $config->{INCLUDE_PATH} = $include_path;
    
    # Call original BUILDARGS
    return $class->$orig($app,$config);
};

{
    no warnings 'once';
    
    $Template::Stash::SCALAR_OPS->{'isa'} = sub { 
        shift; return ( $_[0] eq 'SCALAR' ) ? 1 : 0 
    };
    $Template::Stash::LIST_OPS->{'isa'} = sub { 
        shift; return ( $_[0] eq 'LIST' || $_[0] eq 'ARRAY' ) ? 1 : 0 
    };
    $Template::Stash::HASH_OPS->{'isa'} = sub { 
        shift; return ( $_[0] eq 'HASH' ) ? 1 : 0 
    };
    $Template::Stash::LIST_OPS->{'findlist'} = sub {
        my $list = shift;
        my $item = shift;
        return ( grep { $item eq $_ } @$list ) ? 1 : 0;
    };
    $Template::Stash::HASH_OPS->{'json'} = sub { 
        my $hash = shift; JSON::encode_json($hash);
    };
    $Template::Stash::LIST_OPS->{'json'} = sub { 
        my $list = shift; JSON::encode_json($list);
    };
}


__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
no Moose;
1;
