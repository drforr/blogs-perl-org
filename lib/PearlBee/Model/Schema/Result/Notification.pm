use utf8;
package PearlBee::Model::Schema::Result::Notification;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PearlBee::Model::Schema::Result::Notification - User notifications.

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 TABLE: C<blog>

=cut

__PACKAGE__->table("notification");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 old_status

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 viewed

  data_type: 'boolean'
  is_nullable: 0
  default: 0

=head2 created_date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 user_id

  data_type: 'integer'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "old_status",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "viewed",
  { data_type => "boolean", is_nullable => 0, size => 255 },
  "created_date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "user_id",
  { data_type => "integer", is_auto_increment => 0, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-11-23 12:42:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+4GfXXhfi8fjp4nRVfcIag


# You can replace this text with custom code or comments, and it will be preserved on regeneration

=head2 as_hashref

Return a non-blessed version of a notification database row

=cut

sub as_hashref {
  my ($self)       = @_;
  my $blog_as_href = {
    id           => $self->id,
    name         => $self->name,
    old_status   => $self->old_status,
    viewed       => $self->viewed,
    created_date => $self->created_date,
    user_id      => $self->user_id,
  };          
              
  return $blog_as_href;
}             

=head2 as_hashref_sanitized

Remove ID from the notification database row

=cut

sub as_hashref_sanitized {
  my ($self) = @_;
  my $href   = $self->as_hashref;

  delete $href->{id};
  return $href;
}

1;
