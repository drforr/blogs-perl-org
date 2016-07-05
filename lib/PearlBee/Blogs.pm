package PearlBee::Blogs;

=head1 PearlBee::Blog

Blog routes

=cut

use Dancer2 0.163000;
use Dancer2::Plugin::DBIC;
use PearlBee::Helpers::Util qw(map_posts);
use PearlBee::Helpers::Notification_Email;
use PearlBee::Helpers::Pagination qw(get_total_pages get_previous_next_link);
use DateTime::TimeZone;

our $VERSION = '0.1';

=head2 /blogs/user/:username/slug/:slug ; /users/:username

View blog posts by username and blog slug

=cut

#http://139.162.204.109:5030/blogs/user/pmurias/slug/a_blog_about_the_perl_programming_language

get '/users/:username' => sub {

  my $username = route_parameters->{'username'};
  my $slug     = 'foo';

  redirect "/blogs/user/$username/slug/$slug"
};

get '/blogs/user/:username/slug/:slug' => sub {

  my $num_user_posts = config->{blogs}{user_posts} || 10;
  my $slug        = route_parameters->{'slug'};
  my $username    = route_parameters->{'username'};
  my ( $user )    = resultset('Users')->match_lc( $username );
  my @blog_ids;
  my @posts;
  unless ($user) {
    return error "No such user '$username'";
  }
  my ( $searched_blog ) = resultset('Blog')->find_by_slug_uid({
    slug => $slug, user_id => $user->id
  });

  push @blog_ids, resultset('BlogPost')->search({ blog_id => $searched_blog->id });

  foreach my $iterator (@blog_ids){
    push @posts, resultset('Post')->search (
      { id => $iterator->post_id},
      { order_by => { -desc => "created_date" }, rows => $num_user_posts }
      );
  }

  my $nr_of_posts = scalar @posts;
  # extract demo posts info
  my @mapped_posts = map_posts(@posts);
  my $movable_type_url = config->{movable_type_url};
  my $app_url = config->{app_url};

  for my $post ( @mapped_posts ) {
    $post->{content} =~ s{$movable_type_url}{$app_url}g;
  }

  # Calculate the next and previous page link
  my $total_pages                 = get_total_pages($nr_of_posts, $num_user_posts);
  my ($previous_link, $next_link) = get_previous_next_link(1, $total_pages, '/posts/user/' . $username);

  my @blog_owners = resultset('BlogOwner')->search({ user_id => $user->id });
  my @blogs;
  for my $blog_owner ( @blog_owners ) {
    push @blogs, resultset('Blog')->find({ id => $blog_owner->blog_id });
  }
  
  my @aux_authors = $searched_blog->contributors;

  $searched_blog = $searched_blog->as_hashref_sanitized if $searched_blog;
  my @authors = map { $_->as_hashref_sanitized } @aux_authors;

  template 'blogs',
      {
        posts          => \@mapped_posts,
        page           => 1,
        total_pages    => $total_pages,
        next_link      => $next_link,
        previous_link  => $previous_link,
        posts_for_user => $username,
        blogs          => \@blogs,
        user           => $user,
        authors        => \@authors,
        searched_blog  => $searched_blog,
        nr_of_posts    => $nr_of_posts
    };
};

=head2 /blogs/user/:username/slug/:slug/page/:page route

 View posts for username by page

=cut

get '/blogs/user/:username/slug/:slug/page/:page' => sub {

  my $num_user_posts = config->{blogs}{user_posts} || 10;

  my $username    = route_parameters->{'username'};
  my $page        = route_parameters->{'page'};
  my ( $user )    = resultset('Users')->match_lc( $username );
  unless ($user) {
    # we did not identify the user
    error "No such user '$username'";
  }
  my @posts       = resultset('Post')->search_published({ 'user_id' => $user->id }, { order_by => { -desc => "created_date" }, rows => $num_user_posts, page => $page });
  my $nr_of_posts = resultset('Post')->search_published({ 'user_id' => $user->id })->count;
  my @tags        = map { $_->as_hashref_sanitized }
                    map { $_->tag_objects } @posts;
  my @categories  = map { $_->as_hashref_sanitized }
                    map { $_->category_objects } @posts;

  # extract demo posts info
  my @mapped_posts = map_posts(@posts);

  # Calculate the next and previous page link
  my $total_pages                 = get_total_pages($nr_of_posts, $num_user_posts);
  my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, '/posts/user/' . $username);

  my $template_data =
    {
      posts          => \@mapped_posts,
      tags           => \@tags,
      categories     => \@categories,
      page           => $page,
      total_pages    => $total_pages,
      next_link      => $next_link,
      previous_link  => $previous_link,
      posts_for_user => $username,
    };
  if ( param('format') ) {
    my $json = JSON->new;
    $json->allow_blessed(1);
    $json->convert_blessed(1);
    $json->encode( $template_data );
  }
  else {
    template 'blogs', $template_data;
  }
};

=head2 /blogs/slug/:slug/page/:page route

 View authors for a specific blog

=cut

get '/blogs/authors/slug/:slug/page/:page' => sub {

  my $num_authors = config->{blogs}{nr_of_authors} || 5;
  my $page        = route_parameters->{'page'};
  my $slug        = route_parameters->{'slug'};
  my @authors; my $owner;

  my $blog          = resultset('Blog')->find({ slug => $slug });
  my @blog_owners   = resultset('BlogOwner')->search ({ blog_id => $blog->id });
  my $nr_of_authors = resultset('BlogOwner')->search ({ blog_id => $blog->id })->count;

  for my $blog_owner (@blog_owners){
    push @authors, map { $_->as_hashref_sanitized } 
           resultset('Users')->search({ id => $blog_owner->get_column('user_id') });
   }

  # Calculate the next and previous page link
  my $total_pages                 = get_total_pages($nr_of_authors, $num_authors);
  my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, '/blogs/authors/slug/' . $slug);
  
  my $template_data =
    { 
      authors        => \@authors,
      page           => $page,
      total_pages    => $total_pages,
      next_link      => $next_link,
      previous_link  => $previous_link,
    };
  
  if ( param('format') ) {
    my $json = JSON->new;
    $json->allow_blessed(1);
    $json->convert_blessed(1);
    $json->encode( $template_data );
  }
  else {
    template 'blogs', $template_data;
  }
};

=head2 /create-blog

  Create a new blog by making the user a blog owner

=cut

post '/create-blog' => sub{
  my $params   = body_parameters;
  my $user     = resultset('Users')->find_by_session(session);
  unless ( $user and $user->can_do( 'create blog' ) ) {
    if ( $user->id ) {
      my $id = $user->id;
      log "User ID $user tried to create a blog";
    }
    warn "***** Redirecting guest away from /create-blog";
    redirect '/'
  }
  my $blog     = resultset('Blog')->create_with_slug({
    name         => $params->{name},
    description  => $params->{description},
    timezone     => $params->{timezone},
  });

  resultset('BlogOwner')->create({
    blog_id   => $blog->id,
    user_id   => $user->id,
    is_admin  =>"true",
  });
};

=head2 admin/create-blog

  Getter for blog-creation for admins;

=cut

get 'admin/create-blog' => sub{
      my @blogs     = resultset('Blog')->all();
      my @timezones = DateTime::TimeZone->all_names;
      template 'admin/blogs/add',
      {
        blogs => \@blogs,
        timezones => \@timezones
      },
      { layout => 'admin' };
};

=head2 author/create-blog

  Getter for blog-creation for authors;

=cut

get 'author/create-blog' => sub{

      my $user       = resultset('Users')->find_by_session(session);
      my @blogs;
      my @blog_owners = resultset('BlogOwner')->search({ user_id => $user->id });
      for my $blog_owner ( @blog_owners ) {
      push @blogs, map { $_->as_hashref }
                   resultset('Blog')->search({ id => $blog_owner->blog_id });
      }
      template 'admin/blogs/add',{blogs => \@blogs}, { layout => 'admin' };
};

=head2 /add-contributor/user/:username
 
  Add a contributor, making her/him an admin or a simple author.

=cut

post '/add-contributor/blog/:slug/email/:email/role/:role' => sub {
    my $user    = resultset('Users')->find_by_session(session);
    unless ( $user and $user->can_do('create blog_owner') ) {
      warn "***** Redirecting guest away from /add-contributor/blog/:slug/email/:email/role/:role";
      return template 'blog-profile', {
        warning => "You are not allowed to add a contributor to this blog",
      }, { layout => 'admin' };
    }
    my $slug    = route_parameters->{'slug'};
    my $email   = route_parameters->{'email'};
    my $role    = route_parameters->{'role'};
    my $invitee = resultseet('User')->find({ email => $email });
    my $blog    = resultseet('Blog')->find({ slug => $slug });

    if ( $blog ) {
        my $date    = DateTime->now();
        my $token   = generate_hash( $email . $date );
        my $blog_id = $blog->id;
        my $user_id = $user->id;

        my $blog_owner = resultset('BlogOwners')->create({
            user_id        => $user_id,
            blog_id        => $blog_id,
            is_admin       => $role eq 'admin' ? 1 : 0,
            status         => 'inactive', #
            # created_date defaults cleanly
            activation_key => $token,
        });
	my $notification = resultset('Notification')->create_invitation({
            blog_id => $blog_id,
            user_id => $user_id
        });

        PearlBee::Helpers::Notification_Email->announce_contributor(
            user => $user,
            invitee => $invitee,
            config => config
        );
    }
    else {
        template 'blog-profile', {
            warning => 'Could not find chosen blog'
        }
    }
};

1;
