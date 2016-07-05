package PearlBee::Routes::BlogAvatar;

use Dancer2 0.163000;
use Dancer2::Plugin::DBIC;

our $VERSION = '0.1';

# Internal note here - Keep the Routes/ directory clean of little "handlers".
# Given the history of the application anything added here will be replicated
# all over h*ll.

=head2 /blog-avatar-{light,dark}/{large,small}/

=cut

get '/blog-avatar-light/:size/' => sub {
  my $size = route_parameters->{'size'};

  config->{'blog-avatar'}{'default'}{'light'}{$size}
};
get '/blog-avatar-dark/:size/'  => sub {
  my $size = route_parameters->{'size'};

  config->{'blog-avatar'}{'default'}{'dark'}{$size}
};

=head2 /blog-avatar/{large,small}/ route

Avatar route that just returns the theme-based image

=cut

get '/blog-avatar/:size/' => sub {
  my $size = route_parameters->{'size'};

  my $avatar_path = config->{'blog-avatar'}{'default'}{'dark'}{$size};
  my $theme       = session( 'theme' ) || 'dark';

  if ( $theme eq 'light' ) {
    $avatar_path = config->{'blog-avatar'}{'default'}{'light'}{$size}
  }

  send_file $avatar_path;
};


=head2 /blog-avatar/{large,small}/slug/:slug/user/:username route

Blog avatar

=cut

get '/blog-avatar/:size/slug/:slug/user/:username' => sub {

  my $size     = route_parameters->{'size'};
  my $username = route_parameters->{'username'};
  my $slug     = route_parameters->{'slug'};
  my $user     = resultset('Users')->find({ username => $username });
  my $theme    = session( 'theme' ) || 'dark';

  my $avatar_config = config->{'blog-avatar'};
  my $avatar_path   = $avatar_config->{'default'}{'dark'}{$size};

  my $blog = resultset('Blog')->search_by_user_id_and_slug({
    slug    => $slug,
    user_id => $user->id
  });

  if ( $blog and $blog->avatar_path ne '' ) {
    my $path     = $blog->avatar_path;
    $avatar_path = $path if -e "public/$path";
  }
  elsif ( $theme and $theme eq 'light' ) {
    $avatar_path = $avatar_config->{'default'}{'light'}{$size}
  }

  return send_file $avatar_path;
};

1;
