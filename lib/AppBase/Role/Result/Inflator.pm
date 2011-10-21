# ============================================================================
package AppBase::Role::Schema::Inflator;
# ============================================================================
use 5.010;

use Moose::Role;
use namespace::autoclean;

=head3 register_column

Overrides basic register_column method. Adds datetime & bitmask inflators.

=cut

after 'register_column' => sub {
    my ( $self, $column, $info, @rest ) = @_;
    
    return unless defined( $info->{data_type} );

    my $datetime_method;
    given ( lc( $info->{data_type} ) ) {
        when ('timestamp with time zone')   { $datetime_method = 'timestamptz' }
        when ('timestamp without time zone'){ $datetime_method = 'timestamp_without_time_zone' }
        when ('timestamp')                  { $datetime_method = 'timestamp' }
        when ('date')                       { $datetime_method = 'date' }
        when ('time with time zone')        { $datetime_method = 'timetz' }
        when ('time without time zone')     { $datetime_method = 'time_without_time_zone' } 
        when ('time')                       { $datetime_method = 'time' } 
    }

    if ($datetime_method) {
        my ( $parse, $format ) = ( "parse_" . $datetime_method, "format_" . $datetime_method );
        $self->inflate_column(
            $column => {
                inflate => sub {
                    my ( $value, $obj ) = @_;
                    return undef unless $value;
                    my $parser = $obj->result_source->storage->datetime_parser;
                    my $datetime = $parser->$parse($value);
                    $datetime->set_locale($obj->result_source->schema->current_locale) 
                        if ($obj->result_source->schema->can('current_locale'));
                    return $datetime;
                },
                deflate => sub {
                    my ( $value, $obj ) = @_;
                    return undef unless ref $value eq 'DateTime';
                    my $parser = $obj->result_source->storage->datetime_parser;
                    return $parser->$format($value);
                },
            } 
        );
    }
};

#sub set_column {
#    my $self = shift;
#    my ($column) = @_;
#    
#    $self->{_orig_ident} ||= $self->ident_condition;
#  
#    if ($column eq 'modified_by') {
#        $self->{_dirty_columns}{$column} = 1;
#        return $self->store_column(@_);
#    } else {
#        return $self->next::method(@_);
#    }
#}

no Moose::Role;
1;
