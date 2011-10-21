# ============================================================================
package AppBase::Schema::ResultBase;
# ============================================================================
use 5.010;

use Moose -traits => 'AppBase::Meta::Trait::Class::DBIC';
use DBIx::Class::MooseColumns;
use namespace::autoclean;

extends qw(DBIx::Class::Core
    DBIx::Class::InflateColumn 
    DBIx::Class::PK);

with qw(AppBase::Schema::Component::Inflator 
    AppBase::Schema::Component::Utils);

__PACKAGE__->mk_classaccessor('registered_relations');
__PACKAGE__->table("NONE");

has 'id' => (
    isa => 'Int',
    is  => 'rw',
    add_column => {
        is_auto_increment => 1,
        data_type => "integer",
        default_value => "nextval('appbase.agent_id_seq'::regclass)",
        is_nullable => 0,
        size => 4,
    },
);

has [qw(created modified)] => (
    isa => 'DateTime',
    is  => 'rw',
    add_column => {
        data_type => "timestamp without time zone",
        default_value => "now()",
        is_nullable => 0,
        size => 8,
    },
);

has 'modified_by' => (
    isa => 'AppBase::Schema::Result::Agent',
    is  => 'rw',
    required => 1,
    add_column => {
        data_type => "integer",
        default_value => undef,
        is_nullable => 0,
        size => undef,
    },
);

__PACKAGE__->set_primary_key("id");

sub finalize {}

sub register_relation {
    my ($self,$params) = @_;
    my $registered_relations = $self->registered_relations || [];
    push (@$registered_relations,$params);
    $self->registered_relations($registered_relations);
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );
no Moose;
1;