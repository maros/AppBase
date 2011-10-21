# ============================================================================
package AppBase::Schema;
# ============================================================================
use 5.010;

use Moose;
extends 'DBIx::Class::Schema';

use Moose::Util::TypeConstraints;

__PACKAGE__->load_namespaces(
   result_namespace         => '+AppBase::Schema::Result',
   resultset_namespace      => '+AppBase::Schema::ResultSet',
   default_resultset_class  => '+AppBase::Schema::ResultSetBase',
);

__PACKAGE__->finalize();

sub register_class {
    my ($self, $moniker, $component_class) = @_;
    
    $self->next::method($moniker,$component_class);
    
    # Generate auto type-constraint
    my $type_constraint_meta = Moose::Meta::TypeConstraint::Union->new(
        name            => $component_class,
        type_constraints=> [
            class_type($component_class),
            find_type_constraint('Int'),
        ], # TODO accept null/maybe
    );
    
    register_type_constraint($type_constraint_meta);
}

sub finalize {
    my ($self) = @_;
    
    
    foreach my $source ($self->sources) {    
        my $source_class = $self->class($source);
        my $registered_relations = $source_class->registered_relations;
        next
            unless defined $registered_relations;
        foreach my $relation (@$registered_relations) {
            my $package = $relation->{package};
            my $type = $relation->{type};
            my $params = $relation->{params};
            $package->$type(@$params);
        }
    }
}

1;
