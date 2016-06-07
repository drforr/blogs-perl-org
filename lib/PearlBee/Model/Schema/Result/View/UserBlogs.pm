package PearlBee::Model::Schema::Result::View::UserBlogs;

# This view is used for grabbing comments per user

use strict;
use warnings;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table_class('DBIx::Class::ResultSource::View');
__PACKAGE__->table('blog');
__PACKAGE__->result_source_instance->is_virtual(1);

__PACKAGE__->result_source_instance->view_definition(
    q[
      SELECT
        B.id AS id,
        B.name AS name,
        B.slug AS slug, 
        B.description AS description,
        B.created_date AS created_date,
        B.edited_date AS edited_date,
        B.status AS status,
        B.email_notification AS email_notification,
        B.social_media AS social_media,
        B.multiuser AS multiuser,
        B.accept_comments AS accept_comments,
        B.timezone AS timezone,
        B.avatar_path AS avatar_path,
        bo.blog_id AS bo_id,
        U.id AS user_id
    FROM
      blog AS B
      INNER JOIN
        blog_owners bo
        ON
          bo.blog_id = B.id
      INNER JOIN users U
        ON
          bo.user_id = U.id
    WHERE
      U.id = ?
  ]
);

__PACKAGE__->load_components(qw/InflateColumn::DateTime/);
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
  "bo_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "user_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");
=head2 bo

Type: belongs_to

Related object: L<PearlBee::Model::Schema::Result::User>

=cut

__PACKAGE__->belongs_to(
  "bo_id",
  "PearlBee::Model::Schema::Result::BlogOwner",
  { blog_id => "id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

__PACKAGE__->belongs_to(
  "user_id",
  "PearlBee::Model::Schema::Result::Users",
  { id => "id" },
  {
    is_deferrable => 1,
    join_type     => "LEFT",
    on_delete     => "RESTRICT",
    on_update     => "RESTRICT",
  },
);

1;
