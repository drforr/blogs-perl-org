package PearlBee::Model::Schema::Result::View::Count::StatusBlogs;

# This view is used for counting all blogs for the (super)admin.

use strict;
use warnings;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');
__PACKAGE__->table('blog');
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(
    q[
      SELECT
        SUM( CASE WHEN B.status = 'inactive'  THEN 1 ELSE 0 END ) AS inactive,
        SUM( CASE WHEN B.status = 'active' THEN 1 ELSE 0 END ) AS active,
        COUNT(*)                                                 AS total
      FROM
        blog as B
  ]
);

__PACKAGE__->add_columns(
  "inactive",
  { data_type => "integer", is_nullable => 0 },
  "active",
  { data_type => "integer", is_nullable => 0 },
    "total",
  { data_type => "integer", is_nullable => 0 },
);

=head2 get_all_status_counts

=cut

sub get_all_status_counts {
  my ($self) = @_;

  return ( $self->total, $self->inactive, $self->active );
}

=head2 get_status_count

=cut

sub get_status_count {
  my ($self, $status) = @_;

  return ( $status eq 'inactive' ) ? $self->inactive :  $self->active  ;
}

1;
