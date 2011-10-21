# ============================================================================
package AppBase::Role::Catalyst::Exception;
# ============================================================================

use Moose::Role;
requires qw(finalize_error finalize);

use Try::Tiny;

BEGIN {
    no warnings 'once';
    $Catalyst::Exception::CATALYST_EXCEPTION_CLASS = 'AppBase::X::Catalyst';
}

around 'finalize_error' => sub {
    my $orig = shift;
    my $c = shift;
    
    my $error = $c->error->[ 0 ];
    my $user_checked = $c->can('user_exists') ? ($c->user_exists ? 1:0) : 1;
    
    if ( !Scalar::Util::blessed( $error ) or !$error->isa( 'AppBase::X' ) ) {
        unless ($c->action) {
            $error = AppBase::X::Catalyst::Notfound->new( 
                error       => $error,
                show_trace  => 0
            );
        } else {
            warn 'Exception (should not happen): '.$error.' -> '.ref $error;
            $error = AppBase::X::Catalyst->new( 
                error       => $error,
                ignore_class=> ['AppBase::Catalyst::Plugin::Exception']
            );
        }
    }
    
    $c->stash->{error_object} = $error;
    $c->stash->{error_message} = ( ref $error->full_message eq 'ARRAY'  ?
        $c->maketext_simple(@{ $error->full_message }) : 
        $error->full_message  );
    $c->stash->{is_error} = 1;
    
    # Forbidden
    if ($error->isa('AppBase::X::Catalyst::Forbidden') && $user_checked) {
        $c->response->status(403);
        $error->show_trace(0);
        $c->stash->{template} = 'errors/forbidden.tt';
    # Unauthorized
    } elsif ($error->isa('AppBase::X::Catalyst::Unauthorized') ||
        $error->isa('AppBase::X::Catalyst::Forbidden')) {
        $error->show_trace(0);
        $c->response->status(401);
        $c->session->{_last_stable_base} = $c->req->uri->path_query;
        if (defined $c->config->{'Validad::SingleSignOn'}) {
            $c->forward('/sso/login');
        } else {
            $c->stash->{error_message} = $c->maketext_simple('You have to log in to view the requested page');
            $c->res->redirect($c->uri_for('/login'));
        }
    # Notfound
    } elsif ($error->isa('AppBase::X::Catalyst::Notfound')) {
        $c->response->status(404);
        $error->show_trace(0);
        $c->stash->{template} = 'errors/notfound.tt';
    # Server error
    } else {
        # //= does not work, because undefined message is empty 
        # string!
        $error->{message} = $c->maketext_simple(@{$error->{message}})
            if ref $error->{message} eq 'ARRAY';
        
        $error->{message} ||= ref($error).": ".$error->description;

        if( $c->debug ) {
            return $c->$orig(@_);
        } else {
            $c->stash->{error_message} ||= $error->message;
            $c->response->status(500);
            $c->stash->{template} = 'errors/servererror.tt';
        }
    }
    #$c->log->warn(ref($error). ' -> '.$error. ' ->'.$c->stash->{template}.' -> '.$c->stash->{error_message});
    
    unless ($c->res->redirect) {
        $c->res->content_type('text/html; charset=utf-8');
        
        my $output;
        try {
            $output = $c->view('TT')->render(
                $c,
                $c->stash->{template},
                $c->stash,
            );
        } catch {
            my $error = $_;
            warn $error;
            my $message = ($error->type // '') . $error->info;
            $c->error($message);
            $c->log->error($message);
            return $c->$orig(@_);
        };
        
        $c->res->body(Encode::encode_utf8($output));
    }
};

before 'finalize' => sub {
    my ($c) = shift;
    
    if (! $c->response->content_type
        || $c->response->content_type  =~ /^application\/xhtml\+xml/) {
        $c->res->content_type('text/html; charset=utf-8');
    }
};

1;
