package PearlBee::Blogs;

=head1 PearlBee::Blog

Blog routes

=cut

use Dancer2 0.163000;
use Dancer2::Plugin::DBIC;
use PearlBee::Helpers::Util qw(map_posts);
use PearlBee::Helpers::Pagination qw(get_total_pages get_previous_next_link);
use Try::Tiny;
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
  my $slug = route_parameters->{slug};
  my $username    = route_parameters->{'username'};
  my ( $user )    = resultset('Users')->match_lc( $username );
  unless ($user) {
    error "No such user '$username'";
  }
  my @authors;
  my @posts       = resultset('Post')->search_published({ 'user_id' => $user->id }, { order_by => { -desc => "created_date" }, rows => $num_user_posts });
  my $nr_of_posts = resultset('Post')->search_published({ 'user_id' => $user->id })->count;
  my @tags        = resultset('View::PublishedTags')->all();
  my @categories  = resultset('View::PublishedCategories')->search({ name => { '!=' => 'Uncategorized'} });

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
    push @blogs, map { $_->as_hashref_sanitized }
                 resultset('Blog')->find({ id => $blog_owner->blog_id });
  }
  

  my $blog = resultset('Blog')->find ({slug =>$slug});
  my $nr_of_authors = resultset('BlogOwner')->search ({blog_id => $blog->id})->count;

  for my $blog_owner (@blog_owners){
    push @authors, map { $_->as_hashref_sanitized } 
                   resultset('Users')->search({ id => $blog_owner->get_column('user_id') });
   }
  # Extract all posts with the wanted category


  template 'blogs',
      {
        posts          => \@mapped_posts,
        tags           => \@tags,
        page           => 1,
        categories     => \@categories,
        total_pages    => $total_pages,
        next_link      => $next_link,
        previous_link  => $previous_link,
        posts_for_user => $username,
        blogs          => \@blogs,
        user           => $user,
        nr_of_authors  => $nr_of_authors,
        authors        => \@authors
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

=head2 /create-blog

  Getter for blog-creation

=cut

get '/create-blog' => sub{
      template 'admin/blogs/add',{}, { layout => 'admin' };
};


=head2 /add-contributor
 
  Add a contributor, making her/him an admin or a simple author.

=cut

post '/add-contributor' => sub {
  my $params   = body_parameters;
  my $message;
  #my $date   = DateTime->now();
  #my $token  = generate_hash( $params->{'email'} . $date );
  my $user   = resultset('Users')->find_by_session(session);
  my $role   = $params->{role};
  #my $blog   = resultset('Blog')->find({name => params->{blog}});
  my $blog;

  my @blog_owners = resultset('BlogOwner')->search({ user_id => user->id, is_admin => '1' });
  for my $blog_owner ( @blog_owners ) {
  $blog = resultset('Blog')->search({ id => $blog_owner->blog_id, name => $params->{blog} });
  }
  my $contributor = resultset('Users')->find({email => params->{email}});
  if ($blog) { # i.e. the session_user is an admin and can add contributors
      try {
      PearlBee::Helpers::Email::send_email_complete({
        template => 'Admin.tt',
        from     => config->{'default_email_sender'},
        to       => $user,
        subject  => 'You have a new contributor on your blog',

        template_params => {
          config     => config,
          name       => $user->name,
          username   => $user->username,
          email      => $user->email,
          added_user => $contributor ->name
          #signature => config->{'email_signature'}
        }
      });
 
      PearlBee::Helpers::Email::send_email_complete({
        template => 'contributor.tt',
        from     => config->{'default_email_sender'},
        to       => $params->{email},
        subject  => "You have been added as a contributor",

        template_params => {
          config    => config,
          name      => $contributor->name,
          username  => $contributor->username,
          #mail_body => "/activation?token=$token",
        }
      });
    }
    catch {
      error $_;
    };
      if ($role eq 'admin'){
            resultset('BlogOwner')->create({
            blog_id  => $blog->id,
            user_id  => $contributor->id,
            is_admin =>"true",
          });
      }
      else {
            resultset('BlogOwner')->create({
            blog_id  => $blog->id,
            user_id  => $contributor->id,
            is_admin =>"false",
          });
      }
      $message = 'A new contributor was added';
      template 'blog-profile', {
      success => $message
    };
  }
  else {
      $message = 'You do not have the rights to add a contributor';
      template 'blog-profile', {
      warning => $message
    };
  }
};

1;
