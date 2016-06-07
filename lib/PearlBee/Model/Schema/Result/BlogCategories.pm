use utf8;
package PearlBee::Model::Schema::Result::BlogCategories;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

PearlBee::Model::Schema::Result::BlogCategories - Blog category table.

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<blog_categories>

=cut

__PACKAGE__->table("blog_categories");

=head1 ACCESSORS

=head2 blog_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 category_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "blog_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "category_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</blog_id>

=item * L</category_id>

=back

=cut

__PACKAGE__->set_primary_key("blog_id", "category_id");

=head1 RELATIONS

=head2 blog

Type: belongs_to

Related object: L<PearlBee::Model::Schema::Result::Blog>

=cut

__PACKAGE__->belongs_to(
  "blog",
  "PearlBee::Model::Schema::Result::Blog",
  { id => "blog_id" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);

=head2 category

Type: belongs_to

Related object: L<PearlBee::Model::Schema::Result::Category>

=cut

__PACKAGE__->belongs_to(
  "category",
  "PearlBee::Model::Schema::Result::Category",
  { id => "category" },
  { is_deferrable => 1, on_delete => "RESTRICT", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2015-02-23 16:54:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:X6jXKbLzGuv5nx7NvsFNwA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
