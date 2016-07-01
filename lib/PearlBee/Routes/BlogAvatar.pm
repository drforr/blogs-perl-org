package PearlBee::Routes::BlogAvatar;

use Dancer2 0.163000;
use Dancer2::Plugin::DBIC;

our $VERSION = '0.1';

# Internal note here - Keep the Routes/ directory clean of little "handlers".
# Given the history of the application anything added here will be replicated
# all over h*ll.

get '/blog-avatar-light' => sub {
  config->{'blog-avatar'}{'default'}{'light'}
};
get '/blog-avatar-dark'  => sub {
  config->{'blog-avatar'}{'default'}{'dark'}
};

=head2 /blog-avatar/ route

Avatar route that just returns the theme-based image

=cut

get '/blog-avatar/' => sub {
  my $avatar_path = config->{'blog-avatar'}{'default'}{'dark'};
  my $theme       = session( 'theme' ) || 'dark';

  if ( $theme eq 'light' ) {
    $avatar_path = config->{'blog-avatar'}{'default'}{'light'}
  }

  send_file $avatar_path;
};


=head2 /blog-avatar/slug/:slug/user/:username route

Blog avatar

=cut

get '/blog-avatar/slug/:slug/user/:username' => sub {

  my $username = route_parameters->{'username'};
  my $slug     = route_parameters->{'slug'};
  my $user     = resultset('Users')->find({ username => $username });
  my $theme    = session( 'theme' ) || 'dark';

  my $avatar_config = config->{'blog-avatar'};
  my $avatar_path   = $avatar_config->{'default'}{'dark'};

  my $blog = resultset('Blog')->search_by_user_id_and_slug({
    slug    => $slug,
    user_id => $user->id
  });

  if ( $blog and $blog->avatar_path ne '' ) {
    my $path = $blog->avatar_path;
    $avatar_path = $path if -e "public/$path";
  }
  elsif ( $theme and $theme eq 'light' ) {
    $avatar_path = $avatar_config->{'default'}{'light'}
  }

  return send_file $avatar_path;
};

1;
