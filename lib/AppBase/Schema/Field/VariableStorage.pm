# ============================================================================
package AppBase::Schema::Field::VariableStorage;
# ============================================================================
use 5.010;

use Moose::Role;
use DBIx::Class::MooseColumns;
use JSON::Any;

before 'finalize' => sub {
    my ($self) = @_;
    
    my $json = JSON::Any->new( utf8 => 1 );
    
    $self->inflate_column(
        'storage' => {
            inflate => sub {
                my ( $value, $obj ) = @_;
                return undef unless $value;
                return $json->from_json($value);
            },
            deflate => sub {
                my ( $value, $obj ) = @_;
                return undef unless ref $value eq 'HASH';
                return $json->to_json($value);
            },
        } 
    );
};

has 'storage' => (
    isa => 'HashRef',
    is  => 'rw',
    add_column => {
        data_type => "character varying",
        default_value => undef,
        is_nullable => 1,
        size => undef,
    },
);

no Moose::Role;

1;

