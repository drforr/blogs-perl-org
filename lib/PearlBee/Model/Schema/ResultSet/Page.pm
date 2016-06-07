package  PearlBee::Model::Schema::ResultSet::Page;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';

use PearlBee::Helpers::Util qw/string_to_slug generate_new_slug_name/;

use String::Util qw(trim);

=head2 can_create

Create a new page

=cut

sub can_create {
  my ($self, $params) = @_;

  my $title   = $params->{title};
  my $slug    = $params->{slug};
  my $content = $params->{content};
  my $user_id = $params->{user_id};
  my $status  = $params->{status};
  my $cover   = $params->{cover};
  my $blog    = $params->{blog};

  my $page = $self->create_with_slug({
    title   => $title,
    content => $content,
    user_id => $user_id,
    status  => $status,
    cover   => $cover,
  });

  my $blog_page = $self->create({
    blog_id => $blog,
    page_id => $page->id
  });

  return $page;
}

=item check_slug

Check if the slug is already used, if so generate a new slug or return the old one

=cut

sub check_slug {
  my ($self, $slug, $page_id) = @_;
  
  my $schema = $self->result_source->schema;
  $slug      = string_to_slug( $slug );
  
  my $found_slug   = $page_id
  			? $schema->resultset('Page')->search({ id => { '!=' => $page_id }, slug => $slug })->first
  			: $schema->resultset('Page')->find({ slug => $slug });
  my $slug_changed = 0;
  
  if ( $found_slug ) {
    # Extract the pages w_ith slugs starting the same with the submited slug
    my @pages_with_same_slug = $schema->resultset('Page')->search({ slug => { like => "$slug%"}});
    my @slugs = map { $_->slug } @pages_with_same_slug;
    
    $slug         = generate_new_slug_name($slug, \@slugs);
    $slug_changed = 1;
  }
  
  return ($slug, $slug_changed);
}

=head2 page_slug_exists

=cut

sub page_slug_exists {
  my ($self, $slug, $user_id) = @_;

  my $schema = $self->result_source->schema;
  my $page   = $schema->resultset('Page')->search({ slug => $slug, user_id => $user_id })->first();

  return $page
}

=head2 nr_of_comments

Get the number of comments for this page

=cut

sub nr_of_comments {
  my ($self) = @_;

  my @comments = grep { $_->status eq 'approved' } $self->comments;

  return scalar @comments;
}

=head2 get_string_tags

Get all tags as a string sepparated by a comma

=cut

sub get_string_tags {
  my ($self) = @_;

  my @page_tags   = $self->page_tags;
  my @tag_names   = map { $_->tag->name } @page_tags;
  my $joined_tags = join(', ', @tag_names);

  return $joined_tags;
}

=head2 publish

Status updates

=cut

sub publish {
  my ($self, $user) = @_;

  $self->update({ status => 'published' }) if
    $self->is_authorized( $user );
}

=head2 draft

=cut

sub draft {
  my ($self, $user) = @_;

  $self->update({ status => 'draft' }) if
    $self->is_authorized( $user );
}

=head2 trash

=cut

sub trash {
  my ($self, $user) = @_;

  $self->update({ status => 'trash' }) if
    $self->is_authorized( $user );
}

=head2 is_authorized

Check if the user has enough authorization for modifying

=cut

sub is_authorized {
  my ($self, $user) = @_;

  my $schema     = $self->result_source->schema;
  $user          = $schema->resultset('Users')->find( $user->{id} );
  my $authorized = 0;
  $authorized    = 1 if ( $user->is_admin );
  $authorized    = 1 if ( !$user->is_admin && $self->user_id == $user->id );

  return $authorized;
}

=head2 get_recent_pages

=cut

sub get_recent_pages {
  my ($self) = @_;

  return $self->search({
  	status => 'published'
  	},{
  		order_by => {
  			-desc => "created_date"
  		}, rows => 3
	});
}

=head2 search_published

=cut

sub search_published {
  my ( $self, @args ) = @_;

  $args[0]{status} = 'published';
  return $self->search( @args );
}

=head2 create_with_slug

Create page with internally-generated slug

=cut

sub create_with_slug {
  my ($self, $args) = @_;
  my $schema = $self->result_source->schema;
  my $slug   = string_to_slug( $args->{description} );
  $slug      = $args->{slug} if $args->{slug} and $args->{slug} ne '';

  $schema->resultset('Page')->create({
    title        => $args->{title},
    slug         => $slug,
    description  => $args->{description},
    cover        => $args->{cover},
    content      => $args->{content},
    content_more => $args->{content_more},
    type         => $args->{type},
    status       => $args->{status},
    user_id      => $args->{user_id},
  });
}

1;
