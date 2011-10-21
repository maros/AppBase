# ============================================================================
package AppBase::Role::Catalyst::SessionStore;
# ============================================================================

use Moose;
extends qw/Catalyst::Plugin::Session::Store/;

sub get_session_data {
    my ($c,$key) = @_;
    warn('CALLED get_session_data '.$key);
}

sub store_session_data {
    my ($c,$key,$data) = @_;
    warn('CALLED store_session_data '.$key.'->'.$data);
}

sub delete_session_data {
    my ($c,$key) = @_;
    warn('CALLED delete_session_data '.$key);
}

sub delete_expired_sessions {
    my ($c) = @_;
    warn('CALLED delete_expired_sessions');
}

sub setup_session {
    my ($c) = @_;
    warn('CALLED setup_session');
}

__PACKAGE__->meta->make_immutable;
no Moose;
1;