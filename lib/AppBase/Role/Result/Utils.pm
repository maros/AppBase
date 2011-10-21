# ============================================================================
package AppBase::Role::Schema::Utils;
# ============================================================================
use 5.010;

use Moose::Role;
use namespace::autoclean;

=head3 clone

Clone object

=cut

sub clone {
    my ($self) = @_;
    
    my $result_source = $self->result_source;
    my $data = {};
    
    foreach my $column ($result_source->columns) {
        next if grep { $column eq $_ } qw(id modified modified_by created);
        $data->{$column} = $self->$column();
    }
    
    my $item = $self->result_source->resultset->new($data);
    
    return $item;
}

=head3 jsondata

Return basic json data

=cut

sub jsondata {
    my ($self,@fields) = @_;
        
    my $json = {
        id       => $self->id,
        classref => $self->classref,
    }; 
    
    foreach my $field (@fields) {
        next 
            if ref ($field);
        next 
            unless $self->can($field);
        $json->{$field} = $self->$field;
    }

    foreach my $value ( values %{$json} ) {
        next 
            unless defined $value && ref $value;
        next 
            if ref $value eq 'HASH' || ref $value eq 'ARRAY'; 
        given ($value) {
            when ( $_->isa('DateTime') ) {
                my $clone = $_->clone;
                $clone->locale('en');
                $value = $clone->strftime('%B %d, %Y %T');
            }
            when ( $_->isa('DBIx::Class::Row') ) {
                $value = $_->jsondata;
            }
        }
    }  
    return $json;
}

=head3 many_to_many

Sets a m2m_$name accessor for many_to_many relationships with extra values

    __PACKAGE__->many_to_many(
        'roles',
        'usr_roles',
        'role',
        {
            fields  => ['permission']
        });
        
The C<m2m_$name> method returns and accepts a hashref in the following format

    {
        $role_id    => {
            _object     => $usr_roles_object, # optional
            _related    => $roles_object, # optional
            $field1_key => $field1_value,
            $field2_key => $field2_value,
            ...,
        }
    }

=cut

sub many_to_many {
    my ($class, $accessor_name, $link_rel_name, $foreign_rel_name, $attr) = @_;
    $attr ||= {};
    
    $class->next::method( $accessor_name, $link_rel_name, $foreign_rel_name, $attr );
    
    if (defined $attr->{fields} && ref $attr->{fields} eq 'ARRAY') {
        no strict 'refs';
        *{"${class}::m2m_${accessor_name}"} = sub {
            my $self = shift;   
            my $value = shift;

            my $return = {};
            my $rs = $self->search_related(
                $link_rel_name,
                {},
                {
                    prefetch    => $foreign_rel_name,
                }
            );
            while (my $m2m = $rs->next) {
                my $key = $m2m->$foreign_rel_name->id;
                $return->{$key} = {
                    _object     => $m2m,
                    _related    => $m2m->$foreign_rel_name,
                };
                foreach my $field (@{$attr->{fields}}) {
                    $return->{$key}{$field} = $m2m->$field;
                }
            }
            
            if ($value && ref $value eq 'HASH') {
                my $seen = [];
                while (my ($key,$data) = each %$value) {
                    unless (defined $return->{$key}) {
                        $return->{$key} = {};
                        foreach my $field (@{$attr->{fields}}) {
                            $return->{$key}{$field} = $data->{$field};
                        }
                        $return->{$key}{_object} = $self->create_related($link_rel_name,{
                            %{$return->{$key}},
                            $foreign_rel_name   => $key,
                        });
                    } else {
                        my $update = {};
                        foreach my $field (@{$attr->{fields}}) {
                            $return->{$key}{$field} = $data->{$field};
                            $update->{$field} = $data->{$field};
                        }
                        $return->{$key}{_object}->update($update);
                    }
                    push @$seen,$key;
                }
                foreach my $key (keys %{$return}) {
                    $return->{$key}{_object}->delete()
                        unless $key ~~ $seen;
                }
            }
            return $return;
        };
    }
}

1;

