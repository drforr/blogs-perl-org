package PearlBee::Author::Tag;

use Try::Tiny;
use Dancer2;
use Dancer2::Plugin::DBIC;

use PearlBee::Dancer2::Plugin::Admin;

use PearlBee::Helpers::Util qw(string_to_slug);
use PearlBee::Helpers::Pagination qw(get_total_pages get_previous_next_link generate_pagination_numbering);


=head2 /author/tags/page/:page

List the tags which occur in the blogs in which the user is an owner or is contributing to.
Only 5 entries per page.

=cut

get '/author/tags' => sub{
  redirect '/author/tags/page/1';
};
get '/author/tags/page/:page' => sub { 
  
  my $nr_of_rows = 5; # Number of posts per page
  my $page       = params->{page};
  my $user       = resultset('Users')->find_by_session(session);
  my @blog_owners = resultset('BlogOwner')->search({ user_id => $user->id });
  my @blog_posts;
  my @tags;
  my @aux_tags;
  my @post_tags;
  for my $blog_owner ( @blog_owners ) {
  push @blog_posts, 
                   resultset('BlogPost')->search({ blog_id => $blog_owner->blog_id });

  }

  for my $blog (@blog_posts){
    push @post_tags, 
                     resultset('PostTag')->search({ post_id => $blog->post_id });

  }

  for my $tag (@post_tags){
    push @aux_tags, 
                     resultset('Tag')->search({ id => $tag->tag_id});
  } 
  my $all         = scalar (@aux_tags);
  @tags           = splice(@aux_tags,($page-1)*$nr_of_rows,$nr_of_rows);

  
  my $total_pages                 = get_total_pages($all, $nr_of_rows);
  my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, '/author/tags');
  
  my $total_posts     = $all;
  my $posts_per_page  = $nr_of_rows;
  my $current_page    = $page;
  my $pages_per_set   = 5;
  my $pagination      = generate_pagination_numbering($total_posts, $posts_per_page, $current_page, $pages_per_set);


    template 'admin/tags/list',
    {
     all           => $all, 
     page          => $page,
     next_link     => $next_link,
     previous_link => $previous_link,
     action_url    => 'author/tags/page',
     pages         => $pagination->pages_in_set,
     tags          => \@tags 
    }, 
    { layout => 'admin' };
};

=head2 /author/tags/add

Add a new tag

=cut

post '/author/tags/add' => sub {

  my @tags;
  my $name = params->{name};
  my $slug = string_to_slug( params->{slug} );

  my $found_slug_or_name = resultset('Tag')->search({ -or => [ slug => $slug, name => $name ] })->first;

  # Check for slug or name duplicates
  if ( $found_slug_or_name ) {
    @tags = resultset('Tag')->all;

    template 'admin/tags/list', { warning => "The tag name or slug already exists", tags => \@tags } , { layout => 'admin' };
  }
  else {
    try {
      my $tag = resultset('Tag')->create({
        name   => $name,
        slug   => $slug
      });
    }
    catch {
      info "Could not create tag named '$name'";
    };

    @tags = resultset('Tag')->all;

    template 'admin/tags/list', {
      success => "The cateogry was successfully added.",
      tags => \@tags
    }, { layout => 'admin' };
  }

};

=head2 /author/tags/delete/:id

Delete method

=cut

get '/author/tags/delete/:id' => sub {

  my $tag_id = params->{id};
  my $tag    = resultset('Tag')->find( $tag_id );

  # Delete first all many to many dependecies for safly removal of the isolated tag
  try {
    foreach ( $tag->post_tags ) {
      $_->delete;
    }

    $tag->delete;
  }
  catch {
    info $_;
    error "Could not delete tag";
  };

  redirect '/author/tags';

};

=head2 /author/tags/edit/:id

edit method

=cut

any '/author/tags/edit/:id' => sub {

  my $tag_id = params->{id};
  my @tags   = resultset('Tag')->all;
  my $tag    = resultset('Tag')->find( $tag_id );

  my $name = params->{name};
  my $slug = string_to_slug( params->{slug} );

  # Check if the form was submited
  if ( $name && $slug ) {
    my $found_slug = resultset('Tag')->search({ id => { '!=' => $tag->id }, slug => $slug })->first;
    my $found_name = resultset('Tag')->search({ id => { '!=' => $tag->id }, name => $name })->first;

    # Check if the user entered an existing slug
    if ( $found_slug ) {

      template 'admin/tags/list',
        {
        tag     => $tag,
        tags    => \@tags,
        warning => 'The tag slug already exists'
        },
        { layout => 'admin' };

    }
    # Check if the user entered an existing name
    elsif ( $found_name ) {

      template 'admin/tags/list',
        {
        tag     => $tag,
        tags    => \@tags,
        warning => 'The tag name already exists'
        },
      { layout => 'admin' };

    }
    else {
      try {
        $tag->update({
          name => $name,
          slug => $slug
        });
      }
      catch {
        info $_;
        error "Could not update tag named '$name'";
      };

      @tags = resultset('Tag')->all;

      template 'admin/tags/list',
        {
        tag     => $tag,
        tags    => \@tags,
        success => 'The tag was updated successfully'
        },
      { layout => 'admin' };
    }
  }
  else {
    # If the form wasn't submited just list the tags
    template 'admin/tags/list',
      {
      tag  => $tag,
      tags => \@tags
      },
      { layout => 'admin' };
  }

};

1;
