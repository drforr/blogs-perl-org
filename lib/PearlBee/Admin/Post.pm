=head1

Author: Andrei Cacio
Email: andrei.cacio@evozon.com

=cut

package PearlBee::Admin::Post;

use Try::Tiny;
use Dancer2;
use Dancer2::Plugin::DBIC;

use PearlBee::Dancer2::Plugin::Admin;


use PearlBee::Helpers::Util qw/generate_crypted_filename generate_new_slug_name string_to_slug/;
use PearlBee::Helpers::Pagination qw(get_total_pages get_previous_next_link generate_pagination_numbering);

use DateTime;

=head2 /admin/posts; /admin/posts/page/:page

list all posts method per page

=cut

get '/admin/posts' => sub { redirect '/admin/posts/page/1'; };

get '/admin/posts/page/:page' => sub {

    my $nr_of_rows = 5; # Number of posts per page
    my $page       = params->{page};
    my @posts      = resultset('Post')->search( {}, { order_by => { -desc => 'created_date' }, rows => $nr_of_rows, page => $page } );
    my $count      = resultset('View::Count::StatusPost')->first;

    my ($all, $publish, $draft, $trash) = $count->get_all_status_counts;

    # Calculate the next and previous page link
    my $total_pages                 = get_total_pages($all, $nr_of_rows);
    my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, '/admin/posts');

    # Generating the pagination navigation
    my $total_posts     = $all;
    my $posts_per_page  = $nr_of_rows;
    my $current_page    = $page;
    my $pages_per_set   = 7;
    my $pagination      = generate_pagination_numbering($total_posts, $posts_per_page, $current_page, $pages_per_set);
    map { $_->as_hashref } @posts ;
    
    template 'admin/posts/list',
      {
        posts         => \@posts,
        trash         => $trash,
        draft         => $draft,
        publish       => $publish,
        all           => $all,
        page          => $page,
        next_link     => $next_link,
        previous_link => $previous_link,
        action_url    => 'admin/posts/page',
        pages         => $pagination->pages_in_set
      },
      { layout => 'admin' };

};

=head2 list all published posts

=cut

get '/admin/posts/:status/page/:page' => sub {

    my $nr_of_rows = 5; # Number of posts per page
    my $page       = params->{page} || 1;
    my $status     = params->{status};
    my @posts      = resultset('Post')->search( { status => $status }, { order_by => { -desc => 'created_date' }, rows => $nr_of_rows, page => $page } );
    my $count      = resultset('View::Count::StatusPost')->first;

    my ($all, $publish, $draft, $trash) = $count->get_all_status_counts;
    my $status_count                    = $count->get_status_count($status);

    # Calculate the next and previous page link
    my $total_pages                 = get_total_pages($status_count, $nr_of_rows);
    my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, '/admin/posts/' . $status);

    # Generating the pagination navigation
    my $total_posts     = $status_count;
    my $posts_per_page  = $nr_of_rows;
    my $current_page    = $page;
    my $pages_per_set   = 7;
    my $pagination      = generate_pagination_numbering($total_posts, $posts_per_page, $current_page, $pages_per_set);

    template 'admin/posts/list',
      {
        posts         => \@posts,
        trash         => $trash,
        draft         => $draft,
        publish       => $publish,
        all           => $all,
        page          => $page,
        next_link     => $next_link,
        previous_link => $previous_link,
        status        => $status,
        action_url    => 'admin/posts/' . $status . '/page',
        pages         => $pagination->pages_in_set
      },
      { layout => 'admin' };
};

=head2 publish method

=cut

get '/admin/posts/publish/:id' => sub {
    
  my $post_id = params->{id};
  my $post    = resultset('Post')->find($post_id);
  my $user    = session('user');

  try {
    $post->publish($user);
  }
  catch {
    info $_;
    error "Could not publish post for $user->{username}";
  };

  redirect '/admin/posts';

};

=head2 draft method

=cut

get '/admin/posts/draft/:id' => sub {

  my $post_id = params->{id};
  my $post    = resultset('Post')->find($post_id);
  my $user    = session('user');

  try {
    $post->draft($user);
  }
  catch {
    info $_;
    error "Could not set draft mode for post $user->{username}";
  };

  redirect '/admin/posts';
};

=head2 trash method

=cut

get '/admin/posts/trash/:id' => sub {

  my $post_id = params->{id};
  my $post    = resultset('Post')->find($post_id);
  my $user    = session('user');

  try {
    $post->trash($user);
  }
  catch {
    info $_;
    error "Could not trash post for $user->{username}";
  };

  redirect '/admin/posts';

};

=head2 add method

=cut

any '/admin/posts/add' => sub {

    my @categories = resultset('Category')->all();
    my $post;

    try {
        if ( params->{post} ) {
          
          # Set the proper timezone
          #
          my $user              = session('user');
          my $user_obj         = resultset('Users')->find_by_session(session);
          my ($slug, $changed)  = resultset('Post')->check_slug( params->{slug} );
          my $post;             
          my $cover_filename;
          my @blog_owners = resultset('BlogOwner')->search({ user_id => $user_obj->id});
          my @blogs; 
          my $blog;
          for my $blog_owner ( @blog_owners ) {
          push @blogs, map { $_->as_hashref }
                   resultset('Blog')->search({ id => $blog_owner->blog_id });
                 }
          $blog = $blogs[0];     
          session warning => 'The slug was already taken but we generated a similar slug for you! Feel free to change it as you wish.' if ($changed);

          # Upload the cover image first so we'll have the generated filename ( if exists )
          if ( upload('cover') ) {
              my $cover        = upload('cover');
              $cover_filename  = generate_crypted_filename();
              my ($ext)        = $cover->filename =~ /(\.[^.]+)$/;  #extract the extension
              $ext             = lc($ext);
              $cover_filename .= $ext;

              $cover->copy_to( config->{covers_folder} . $cover_filename );
          }

          # Next we can store the post into the database safely
          my $params = {
              title   => params->{title},
              slug    => $slug,
              content => params->{post},
              user_id => $user->{id},
              status  => params->{status},
              cover   => ( $cover_filename ) ? $cover_filename : '',
              type    => params->{type} || 'HTML',
              blog_id => $blog->{id},
          };
          $post = resultset('Post')->can_create($params);
  
          # Insert the categories selected with the new post
          resultset('PostCategory')->connect_categories( params->{category}, $post->id );

          # Connect and update the tags table
          resultset('PostTag')->connect_tags( params->{tags}, $post->id );
        }
    }
    catch {
      info $_;
      error "Could not addd post";
    };

    # If the post was added successfully, store a success message to show on the view
    session success => 'The post was added successfully' if ( !$@ && $post );

    # If the user created a new post redirect him to the post created
    if ( $post ) {
      redirect '/admin/posts/edit/' . $post->slug;
    }
    else {
      template 'admin/posts/add', { categories => \@categories }, { layout => 'admin' };
    }

};

=head2 edit method

=cut

get '/admin/posts/edit/:slug' => sub {

    my $post_slug       = params->{slug};
    my $post            = resultset('Post')->find({ slug => $post_slug });
    my @post_categories = $post->post_categories;
    my @post_tags       = $post->post_tags;
    my @all_categories  = resultset('Category')->all;
    my @all_tags        = resultset('Tag')->all;

    # Prepare tags for the UI
    my @tag_names;
    push( @tag_names, $_->tag->name ) foreach (@post_tags);
    my $joined_tags = join( ', ', @tag_names );

    # Prepare the categories
    my @category_names;
    push( @category_names, $_->category->name ) foreach (@post_categories);
    my $joined_categories = join( ', ', @category_names );


    # Array of post categories id for populating the checkboxes
    my @categories_ids;
    # push( @categories_ids, $_->id ) foreach (@categories);

    my $params = {
        post           => $post,
        tags           => $joined_tags,
        categories     => $joined_categories,
        all_categories => \@all_categories,
        ids            => \@categories_ids,
        all_tags       => \@all_tags
    };

    # Check if there are any messages to show
    # Delete them after stored on the stash
    if ( session('warning') ) {
      $params->{warning} = session('warning');
      session warning => undef
    }
    elsif ( session('success') ) {
      $params->{success} = session('success');
      session success => undef;
    }

    template 'admin/posts/edit', $params, { layout => 'admin' };

};

=head2 update method

=cut

post '/admin/posts/update/:id' => sub {

    my $post_id = params->{id};
    my $post    = resultset('Post')->find({ id => $post_id });
    my $title   = params->{title};
    my $content = params->{post};
    my $tags    = params->{tags};

    my ($slug, $changed) = resultset('Post')->check_slug( params->{slug}, $post->id );
    session warning => 'The slug was already taken but we generated a similar slug for you! Feel free to change it as you wish.' if ($changed);

    try {
        # Upload the cover image
        my $cover;
        my $ext;
        my $crypted_filename;

        if ( upload('cover') ) {

            # If the user uploaded a cover image, generate a crypted name for uploading
            $crypted_filename = generate_crypted_filename();            
            $cover = upload('cover');
            ($ext) = $cover->filename =~ /(\.[^.]+)$/;            #extract the extension
            $ext = lc($ext);
            $cover->copy_to( config->{covers_folder} . $crypted_filename . $ext );
        }

        my $status = params->{status};
        $post->update({
            title   => $title,
            slug    => $slug,
            cover   => ($crypted_filename) ? $crypted_filename . $ext : $post->cover,
            status  => $status,
            content => $content,
        });

        # Reconnect the categories with the new one and delete the old ones
        resultset('PostCategory')->connect_categories( params->{category}, $post->id );

        # Reconnect and update the selected tags
        resultset('PostTag')->connect_tags( params->{tags}, $post->id );

    }
    catch {
        info $_;
        error "Could not upload your post";
    };

    session success => 'The post was updated successfully!';

    redirect '/admin/posts/edit/' . $post->slug;

};

1;
