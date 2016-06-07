package PearlBee::Routes::Notification;

=head1 PearlBee::Routes::Notification

Notification routes

=cut

use Dancer2 0.163000;
use Dancer2::Plugin::DBIC;
use PearlBee::Helpers::Util qw(map_posts);
use PearlBee::Helpers::Pagination qw(get_total_pages get_previous_next_link);

our $VERSION = '0.1';

=head2 /notification

View all notifications

=cut

get '/notification' => sub {

  my $res_user              = resultset('Users')->find_by_session(session);
  my @comment_notifications =
    resultset('Notification')->search(
      { user_id => $user_id,
        name    => 'comment' },
      { order_by => { -desc => 'created_date' } }
    );
  my @invitation_notifications =
    resultset('Notification')->search(
      { user_id  => $user_id,
        name     => 'invitation' });
      { order_by => { -desc => 'created_date' } }
    );

  template 'notification',
    {
      comments   => \@comment_notifications,
      invitation => \@invitation_notifications,
    };

};


=head2 /notification/comment/:id/user/:username/mark-read

View all notifications

=cut

get '/notification/comment/:id/user/:username/mark-read' => sub {

  my $res_user        = resultset('Users')->find_by_session(session);
  my $id              = route_parameters->{'id'};
  my $username        = route_parameters->{'username'};
  my $invitation_user = resultset('Users')->search({ username => $username });
  my $user_id         = $invitation_user->id;

  resultset('Notification')->read_comment({
    comment_id => $id,
    user_id    => $user_id
  });

  redirect '/notification'
};


=head2 /notification/invitation/:id/user/:username/mark-read

View all notifications

=cut

get '/notification/invitation/:id/user/:username/mark-read' => sub {

  my $res_user        = resultset('Users')->find_by_session(session);
  my $username        = route_parameters->{'username'};
  my $id              = route_parameters->{'id'};
  my $invitation_user = resultset('Users')->search({ username => $username });
  my $user_id         = $invitation_user->id;

  resultset('Notification')->read_invitation({
    blog_id => $id,
    user_id => $user_id
  });

  redirect '/notification'
};


=head2 /notification/response/:id/user/:username/mark-read

View all notifications

=cut

get '/notification/response/:id/user/:username/mark-read' => sub {

  my $res_user        = resultset('Users')->find_by_session(session);
  my $username        = route_parameters->{'username'};
  my $id              = route_parameters->{'id'};
  my $invitation_user = resultset('Users')->search({ username => $username });
  my $user_id         = $invitation_user->id;

  resultset('Notification')->read_response({
    blog_id => $id,
    user_id => $user_id
  });

  redirect '/notification'
};


=head2 /notification/changed_role/:id/user/:username/mark-read

View all notifications

=cut

get '/notification/changed_role/:id/user/:username/mark-read' => sub {

  my $res_user        = resultset('Users')->find_by_session(session);
  my $username        = route_parameters->{'username'};
  my $id              = route_parameters->{'id'};
  my $invitation_user = resultset('Users')->search({ username => $username });
  my $user_id         = $invitation_user->id;

  resultset('Notification')->read_changed_role({
    blog_id => $id,
    user_id => $user_id
  });

  redirect '/notification'
};


1;
