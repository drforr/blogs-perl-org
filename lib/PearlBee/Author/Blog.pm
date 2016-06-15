package PearlBee::Author::Blog;

use Try::Tiny;
use Dancer2;
use Dancer2::Plugin::DBIC;

use PearlBee::Helpers::Pagination qw(get_total_pages get_previous_next_link generate_pagination_numbering);

=head2 /author/blogs ; /author/blogs/page/:page

List all the blogs of an author.

=cut

get '/author/blogs' => sub { redirect '/author/blogs/page/1'; };

get '/author/blogs/page/:page' => sub {

  my $nr_of_rows = 5; # Number of posts per page
  my $page       = params->{page} || 1;
  my $user       = resultset('Users')->find_by_session(session);
  my @blogs      = resultset('View::UserBlogs')->search({}, { bind => [ $user->id ], order_by => \"created_date DESC", rows => $nr_of_rows, page => $page });
  my $count      = resultset('View::Count::StatusBlogAuthor')->search({}, { bind => [ $user->id ] })->first;
  my @actual_blogs;
  my ($all, $inactive, $active) = $count->get_all_status_counts;

  # Calculate the next and previous page link
  my $total_pages                 = get_total_pages($all, $nr_of_rows);
  my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, '/author/blogs');

  # Generating the pagination navigation
  my $total_blogs    = $all;
  my $posts_per_page = $nr_of_rows;
  my $current_page   = $page;
  my $pages_per_set  = 7;
  my $pagination     = generate_pagination_numbering($total_blogs, $posts_per_page, $current_page, $pages_per_set);
  foreach my $blog (@blogs){
  push @actual_blogs, 
                  resultset('Blog')->search({ id => $blog->id});
  }
  map { $_->as_hashref } @actual_blogs ;
  template 'admin/blogs/list',
      {
        blogs         => \@actual_blogs,
        all           => $all,
        active        => $active,
        inactive      => $inactive,
        page          => $page,
        next_link     => $next_link,
        previous_link => $previous_link,
        action_url    => 'author/blogs/page',
        pages         => $pagination->pages_in_set
      },
      { layout => 'admin' };

};

=head2 /author/comments/:status/page/:page

List all blogs grouped by status. Maybe they will be needed.

=cut

# get '/author/comments/:status/page/:page' => sub {

#   my $nr_of_rows = 5; # Number of posts per page
#   my $page       = params->{page} || 1;
#   my $status     = params->{status};
#   my $user       = resultset('Users')->find_by_session(session);
#   my @blogs   = resultset('Blog')->search({ status => $status },  { bind => [ $user->id ], order_by => \"created_date DESC", rows => $nr_of_rows, page => $page });
#   my $count       = resultset('View::Count::StatusCommentAuthor')->search({}, { bind => [ $user->id ] })->first;

#   my ($all, $approved, $trash, $spam, $pending) = $count->get_all_status_counts;
#   my $status_count                              = $count->get_status_count($status);

#   # Calculate the next and previous page link
#   my $total_pages                 = get_total_pages($all, $nr_of_rows);
#   my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, '/author/comments/' . $status);

#   # Generating the pagination navigation
#   my $total_comments  = $status_count;
#   my $posts_per_page  = $nr_of_rows;
#   my $current_page    = $page;
#   my $pages_per_set   = 7;
#   my $pagination      = generate_pagination_numbering($total_comments, $posts_per_page, $current_page, $pages_per_set);

# template 'author/blogs/list',
#       {
#         blogs         => \@blogs,
#         all           => $all,
#         active        => $active,
#         inactive      => $inactive,
#         page          => $page,
#         next_link     => $next_link,
#         previous_link => $previous_link,
#         action_url    => 'author/blogs/page',
#         pages         => $pagination->pages_in_set
#       },
#       { layout => 'admin' };


# };


1;
