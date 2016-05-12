use utf8;
package PearlBee::Model::Schema::Result::Blog;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PearlBee::Model::Schema::Result::Blog - Blog information.

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

__PACKAGE__->table("blog");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 description

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 slug

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 created_date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 0

=head2 edited_date

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: '0000-00-00 00:00:00'
  is_nullable: 0

=head2 status

  data_type: 'enum'
  default_value: 'inactive'
  extra: {list => ["inactive","active","suspended","pending"]}
  is_nullable: 0

=head2 email_notification

  data_type: 'enum'
  default_value: 'inactive'
  extra: {list => ["inactive","active","suspended","pending"]}
  is_nullable: 0

=head2 social_media

  data_type: 'boolean'
  is_nullable: 0
  default_value: false

=head2 multiuser

  data_type: 'boolean'
  is_nullable: 0
  default_value: false

=head2 accept_comments

  data_type: 'boolean'
  is_nullable: 0
  default_value: false

=head2 timezone

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 avatar_path

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "name",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "description",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "slug",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "created_date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 0,
  },
  "edited_date",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => "0000-00-00 00:00:00",
    is_nullable => 0,
  },
  "status",
  {
    data_type => "enum",
    default_value => "inactive",
    extra => { list => ["inactive", "active", "suspended", "pending"] },
    is_nullable => 0,
  },
  "email_notification",
  { data_type => "integer", is_auto_increment => 0, is_nullable => 0 },
  "social_media",
  { data_type => "boolean", is_auto_increment => 0, is_nullable => 0 },
  "multiuser",
  { data_type => "boolean", is_auto_increment => 0, is_nullable => 0 },
  "accept_comments",
  { data_type => "boolean", is_auto_increment => 0, is_nullable => 0 },
  "timezone",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "avatar_path",
  { data_type => "varchar", is_nullable => 0, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<name>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("name", ["name"]);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-11-23 12:42:58
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+4GfXXhfi8fjp4nRVfcIag


# You can replace this text with custom code or comments, and it will be preserved on regeneration

=head2 as_hashref

Return a non-blessed version of a blog database row

=cut

sub as_hashref {
  my ($self)       = @_;
  my $blog_as_href = {
    id                 => $self->id,
    name               => $self->name,
    description        => $self->description,
    slug               => $self->slug,
    created_date       => $self->created_date,
    edited_date        => $self->edited_date,
    status             => $self->status,
    email_notification => $self->email_notification,
    social_media       => $self->social_media,
    multiuser          => $self->multiuser,
    accept_comments    => $self->accept_comments,
    timezone           => $self->timezone,
    avatar_path        => $self->avatar_path,
  };          
              
  return $blog_as_href;
}             

=head2 as_hashref_sanitized

Remove ID from the blog database row

=cut

sub as_hashref_sanitized {
  my ($self) = @_;
  my $href   = $self->as_hashref;

  delete $href->{id};
  return $href;
}

1;
