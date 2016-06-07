package PearlBee::Routes::Profile;

=head1 PearlBee::Routes::Profile

Profile routes from the old PearlBee main file

=cut

use Encode qw( decode_utf8 );
use Dancer2 0.163000;
use Dancer2::Plugin::DBIC;

use PearlBee::Helpers::Access qw( has_ability );
use PearlBee::Helpers::ProcessImage;
use Try::Tiny;

our $VERSION = '0.1';

=head2 hook 'before'

=cut

hook before => sub {
  my $user = session('user');
  my $user_obj = resultset('Users')->find_by_session(session);

  if ( request->dispatch_path =~ m{ ^/profile/author }x ) {
    # Do nothing, /profile/author can be viewed by anyone.
  }
  elsif ( request->dispatch_path =~ m{ ^/profile }x ) {
    if ( $user ) {
      if ( !PearlBee::Helpers::Access::has_ability( $user, 'update profile' ) ) {
        forward '/', { requested_path => request->dispatch_path };
      }
    }
  }
};

=head2 /profile route

Display profile page

=cut

get '/profile' => sub {

  template 'profile';

};

=head2 /profile/author/:username route

Display profile for a given author

=cut
  
get '/profile/author/:username' => sub {

  my $nr_of_rows = config->{blogs_on_page} || 5; # Number of posts per page
  my $username   = route_parameters->{'username'};
  my ( $user )   = resultset('Users')->match_lc( $username );

  if ($user) {

    my @blog_owners = resultset('BlogOwner')->search({ user_id => $user->id });
    my @blogs;
    for my $blog_owner ( @blog_owners ) {
      push @blogs, map { $_->as_hashref_sanitized }
                   resultset('Blog')->find({ id => $blog_owner->blog_id });
    }
    my @posts = resultset('Post')->search_published({ user_id => $user->id });
    my @post_tags;
    for my $post ( @posts ) {
      push @post_tags, map { $_->as_hashref_sanitized } $post->tag_objects;
    }
    for my $blog ( @blogs ) {
      $blog->{count} = {
        owners => 1,
        post   => scalar @posts,
        tag    => scalar @post_tags,
      };
      $blog->{post_tags} = \@post_tags;
    }
 
    my $template_data = {
      blogs      => \@blogs,
      blog_count => scalar @blogs,
      user       => $user->as_hashref_sanitized,
    }; 
 
    if (param('format')) {
      my $json = JSON->new;
      $json->allow_blessed(1);
      $json->convert_blessed(1);
      $json->encode( $template_data );
    }     
    else {
      template 'profile/author', $template_data;
    }
  }
  else {
    template 'profile/author';
  }

};

=head2 /profile route

=cut

post '/profile' => sub {

  my $params      = body_parameters;
  my $user        = session('user');
  my $res_user    = resultset('Users')->find_by_session(session);
  my $new_columns = { };
  my @message;

  if ($params->{'email'}) {
    my $existing_user =
      resultset('Users')->search({ email => $params->{'email'} })->count;
    if ($existing_user > 0) {
      push @message, "A user with this email address already exists.";
    }
    else {
      $new_columns->{'email'} = $params->{'email'};
    }
  }

  if ($params->{'username'}) {
    my $existing_user =
      resultset('Users')->search({ username => $params->{'username'} })->count;
    if ($existing_user > 0) {
       push @message, "A user with this username already exists.";
    }
    else {
      $new_columns->{'username'} = $params->{'username'};
    }
  }

  if ($params->{'displayname'}) {
    my $existing_user =
      resultset('Users')->search({ name => $params->{'displayname'} })->count;
    if ($existing_user > 0) {
      push @message, "A user with this displayname already exists.";
    }
    else {
      $new_columns->{'name'} = decode_utf8($params->{'displayname'});
    }
  }

  if ($params->{'about'}) {
    $new_columns->{'biography'} = decode_utf8($params->{'about'});
  }

  if (keys %$new_columns) {
    $res_user->update( $new_columns );
    $user->{$_} = $new_columns->{$_} for keys %$new_columns;
    session('user', $user);

    if ( !@message ) {
      template 'profile',
        { success => "Everything was successfully updated." }
    }
    else {
      template 'profile',
        { warning => "Some fields were updated, but ". join( "\n", @message ) }
    }
  }
  else {
    template 'profile',
      { warning => "No fields changed" }
  }
};

=head2 /profile-image route

=cut

post '/profile-image' => sub {

  my $params   = params;
  my $file     = $params->{file};
  my $user     = session('user');
  my $res_user = resultset('Users')->find_by_session(session);
  my $message;

  my $upload_dir  = "/" . config->{'avatar'}{'path'};
  my $folder_path = config->{user_pics};
  my $filename    = sprintf( config->{'avatar'}{'format'}, $res_user->id );

  if ( $params->{action_form} eq 'crop' ) {
    if ( $params->{width} > 0 ) {
      if ( $params->{file} ) {
        my $logo = PearlBee::Helpers::ProcessImage->new(
          request->uploads->{file}->tempname
        );
        try {
          $logo->resize( $params, $folder_path, $filename );
        } 
        catch {
          info 'There was an error resizing your avatar: ' . Dumper $_;
        };
      }
      else {
        my $logo = PearlBee::Helpers::ProcessImage->new(
          $folder_path . '/' . $filename
        );
#      try {
        $logo->resize( $params, $folder_path, $filename );
#      } 
#      catch {
#        info 'There was an error resizing your avatar: ' . Dumper $_;
#      };
      }
    }

    $res_user->update({ avatar_path => $upload_dir . $filename });
    $user->{avatar_path} = $upload_dir . $filename;
    $message = "Your profile picture has been changed.";
  }
  elsif ( $params->{action_form} eq 'delete' ) {
    $res_user->update({ avatar_path => '' });

    $message = "Your picture has been deleted";
  }
  else {
  }

  session( 'user', $res_user->as_hashref_sanitized );
  template 'profile',
    {
      success => $message
    };
};

=head2 /blog-image/:slug route

Create/update/delete a blog

=cut

post '/blog-image/:slug' => sub {

  my $slug        = route_parameters->{'slug'};
  my $params      = params;
  my $file        = $params->{file};
  my $user        = session('user');
  my $res_user    = resultset('Users')->find_by_session(session);
  my $upload_dir  = "/" . config->{'avatar'}{'path'};
  my $folder_path = config->{user_pics};
  #my $blog        = resultset('Blog')->find({ slug => $slug });
  my @blog_owners = resultset('BlogOwner')->search({ user_id => $res_user->id, is_admin => '1' });
  my $blog;
  my $errorflag = 0;
  for my $blog_owner ( @blog_owners ) {
  $blog = resultset('Blog')->search({ id => $blog_owner->blog_id, slug => $slug });
  }
  my $message;

  if ( $blog ) {
    my $filename = sprintf( config->{'avatar'}{'blog-format'},
                            $blog->id, $res_user->id );

    if ( $params->{action_form} eq 'crop' ) {
      if ( $params->{width} > 0 ) {
        if ( $params->{file} ) {
          my $logo = PearlBee::Helpers::ProcessImage->new(
            request->uploads->{file}->tempname
          );
          try {
            $logo->resize( $params, $folder_path, $filename );
          } 
          catch {
            info 'There was an error resizing your avatar: ' . Dumper $_;
          };
        }
        else {
          my $logo = PearlBee::Helpers::ProcessImage->new(
            $folder_path . '/' . $filename
          );
#        try {
          $logo->resize( $params, $folder_path, $filename );
#        } 
#        catch {
#          info 'There was an error resizing your avatar: ' . Dumper $_;
#        };
        }
      }
    
      $blog->update({ avatar_path => $upload_dir . $filename });
      $message = "Your profile picture has been changed.";
    }
    elsif ( $params->{action_form} eq 'delete' ) {
      $blog->update({ avatar_path => '' });
    
      $message = "Your picture has been deleted";
    }
    else {
    }
  }
  else {
    $message="You do not have the rights to change the blog's picture";
    $errorflag = 1;
  }

  session( 'user', $res_user->as_hashref_sanitized );
  if ($errorflag == 0){
  template 'blog-profile',
    {
      success => $message
    };
  }
  else {
    template 'blog-profile',
    {
      warning => $message
    };
  }
};

=head2 /profile_password route

=cut

post '/profile_password' => sub {
  my $params   = body_parameters;
  my $user     = session('user');
  my $res_user = resultset('Users')->find_by_session(session);
  my $template_data;

  if (defined($res_user) && ($params->{'new_password'} ne '')) {
    
    if ($params->{'new_password'} eq $params->{'confirm_password'}) {
      
      if ($res_user->validate($params->{'old_password'})) {

        my $hashed_password =
          crypt( $params->{'new_password'}, $res_user->password );
        $res_user->update({
          password => $hashed_password,
        });

        $template_data = { success => "You can now use your new password" };

      }
      else {
        $template_data =
          {
            warning => "Please enter your old password correctly",
          };
      }
    }
    else {
      $template_data =
        {
          warning => "Confirmation password was entered incorrectly",
        };
    }

  }
  else {
    $template_data = { warning => "No new password was entered" };
  }
 
  template 'profile', $template_data;
};

=head2 /profile_password route

=cut

get '/profile_password' => sub {

   template 'profile';

};

1;
