package PearlBee::Model::Schema::Result::View::Count::StatusUserNonAdmin;

# This view is used for counting all stauts

use strict;
use warnings;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');
__PACKAGE__->table('user');
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(
    q[
      SELECT
      	SUM( CASE WHEN u.status = 'inactive'  THEN 1 ELSE 0 END ) AS inactive,
      	SUM( CASE WHEN u.status = 'active'    THEN 1 ELSE 0 END ) AS active,
      	SUM( CASE WHEN u.status = 'suspended' THEN 1 ELSE 0 END ) AS suspended,
        SUM( CASE WHEN u.status = 'pending'   THEN 1 ELSE 0 END ) AS pending,
      	COUNT(*)                                                AS total
      FROM users as u
        INNER JOIN 
          blog_owners as bo 
            on u.id = bo.user_id
        INNER JOIN
          blog as b 
            on bo.blog_id = b.id
        INNER JOIN 
          blog_owners as bo2 
            on b.id = bo2.blog_id 
        INNER JOIN 
          users as u2 
            on bo2.user_id = u2.id
  
  where u.id = ?
 
    ]
);

__PACKAGE__->add_columns(
  "inactive",
  { data_type => "integer", is_nullable => 0 },
  "active",
  { data_type => "integer", is_nullable => 0 },
  "suspended",
  { data_type => "integer", is_nullable => 0 },
  "pending",
  { data_type => "integer", is_nullable => 0 },
  "total",
  { data_type => "integer", is_nullable => 0 },
);

=head2 get_all_status_counts

=cut

sub get_all_status_counts {
  my ($self) = @_;
  return ( $self->total, $self->active, $self->inactive, $self->suspended, $self->pending );
}

=head2 get_status_count

=cut

sub get_status_count {
  my ($self, $status) = @_;

  return ( $status eq 'active' ) ? $self->active : ( $status eq 'inactive' ) ? $self->inactive : ( $status eq 'suspended' ) ? $self->suspended : $self->pending;
}

1;
