package  PearlBee::Model::Schema::ResultSet::Blog;

use strict;
use warnings;

use Dancer2;
use Dancer2::Plugin::DBIC;
use PearlBee::Model::Schema;
use PearlBee::Helpers::Util qw( string_to_slug );
use base 'DBIx::Class::ResultSet';

=head2 create_with_slug

Create blog with internally-generated slug

=cut

sub create_with_slug {
  my ($self, $args) = @_;
  my $schema = $self->result_source->schema;
  my $slug   = string_to_slug( $args->{description} );
  $slug      = $args->{slug} if $args->{slug} and $args->{slug} ne '';

  $schema->resultset('Blog')->create({
    name        => $args->{name},
    description => $args->{description},
    timezone    => $args->{timezone},
    slug        => $slug,
  });
}

=head2 search_by_user_id_and_slug({ user_id => 'drforr', slug => 'hi' })

=cut

sub search_by_user_id_and_slug {
  my ($self, $args) = @_;
  my $slug    = $args->{slug};
  my $user_id = $args->{user_id};
  my $schema  = $self->result_source->schema;

  my @matching_pairs = $schema->resultset('BlogOwners')->search({
    user_id => $user_id
  });
  unless ( @matching_pairs ) {
    warn "*** Could not find blog owner for user ID $user_id";
    return;
  }
  my @matching_blogs = map {
    $schema->resultset('Blog')->search({ id => $_->blog_id }) 
  } @matching_pairs;
  unless ( @matching_blogs ) {
    warn "*** Could not find matching blog IDs for user ID $user_id";
    return;
  }
  my $final_blog = grep {
    $_->slug eq $slug
  } @matching_blogs;
  unless ( $final_blog ) {
    warn "*** Could not find blog ID with slug '$slug' for user ID $user_id";
    return;
  }

  return $final_blog;
}

sub search_lc {
  my ($self, $tag) = @_;
  my $schema = $self->result_source->schema;
  my $lc_tag = lc $tag; 
  return $schema->resultset('Blog')->
                  search( \[ "lower(name) like '\%$lc_tag\%'" ] );
}

=head2 find_by_slug_uid({ user_id => $user_id, slug => $slug_name })

Search for a blog by slug and user ID. Multiple blogs can reuse the same slug
name, and in fact most will, so really (slug, user_id) are the proper key to
search on.

=cut

sub find_by_slug_uid {
  my ($self, $args) = @_;
  my $slug          = $args->{slug};
  my $user_id       = $args->{user_id};

  my $schema = $self->result_source->schema;
  my %blog_ids = map {
    $_->blog_id => 1
  } $schema->resultset('BlogOwner')->search({ user_id => $user_id });

  my $blog;
  for my $blog_id ( keys %blog_ids ) {
    my $temp_blog = $schema->resultset('Blog')->find({ id => $blog_id });
    next if $temp_blog->slug ne $slug;
    return $temp_blog
  }

  return;
}

1;
