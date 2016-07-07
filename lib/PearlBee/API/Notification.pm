package PearlBee::API::Notification;

=head1 PearlBee::API::Notification

Notification API

=cut

use Dancer2 0.163000;
use Dancer2::Plugin::DBIC;

our $VERSION = '0.1';

#
# Some notes here - APIs should *not* assume that a session exists.
# This way clients that don't have an account can access data.
#
# Also, everything in this directory should be strictly readonly.
# And never return any form of sequential ID or password information.
#
# If someone gets an ID they can guess the next ID in sequence and preemptorily
# insert or update someoen else's data.
#

=head2 /api/notification/comment/user/:username/page/:page

View page $page of comment notifications for user $username

=cut

get '/api/notification/comment/user/:username/page/:page' => sub {

  my $username = route_parameters->{'username'};
  my $page     = route_parameters->{'page'};
  my ( $user ) = resultset('Users')->match_lc( $username );

  my @notifications =
    resultset('Notification')->search(
      { user_id  => $user->id,
        name     => 'comment' },
      { rows     => config->{api}{notification}{comment}{max_rows},
        page     => $page,
        order_by => { -desc => 'created_date' } }
    );
  my $count_comments = resultset('Notification')->search({
  user_id => $user->id, name => 'comment'
  })->count;
  my %data;
  @notifications = map { $_->as_hashref_sanitized } @notifications;
  $data{total}= $count_comments;
  $data{notifications} = \@notifications;

  # Le sigh, something stuffed up the serializer plugin.  
  my $json = JSON->new;
  $json->allow_blessed(1);
  $json->convert_blessed(1);
  return $json->encode( \%data);

};


=head2 /api/notification/invitation/user/:username/page/:page

View page $page of invitation notifications for user $username

=cut

get '/api/notification/invitation/user/:username/page/:page' => sub {

  my $username = route_parameters->{'username'};
  my $page     = route_parameters->{'page'};
  my ( $user ) = resultset('Users')->match_lc( $username );

  my @notifications =
    resultset('Notification')->search(
      { user_id  => $user->id,
        name     => 'invitation',
        viewed   =>0 },
      { rows     => config->{api}{notification}{comment}{max_rows},
        page     => $page,
        order_by => { -desc => 'created_date' } }
    );

  my $count_invitations = resultset('Notification')->search({
  user_id => $user->id, name => 'invitation', viewed => 0
  })->count;
  my %data;
  @notifications = map { $_->as_hashref_sanitized } @notifications;
  $data{total}         = $count_invitations;
  $data{notifications} = \@notifications;

  # Le sigh, something stuffed up the serializer plugin.  
  my $json = JSON->new;
  $json->allow_blessed(1);
  $json->convert_blessed(1);
  return $json->encode( \%data);
};

=head2 /api/notification/response/user/:username/page/:page

View page $page of response notifications for user $username

=cut

get '/api/notification/response/user/:username/page/:page' => sub {

  my $username = route_parameters->{'username'};
  my $page     = route_parameters->{'page'};
  my ( $user ) = resultset('Users')->match_lc( $username );

  my @notifications =
    resultset('Notification')->search(
      { sender_id  => $user->id,
        name       => 'response' },
      { rows       => config->{api}{notification}{comment}{max_rows},
        page       => $page,
        order_by   => { -desc => 'created_date' } }
    );
  my $count_responses = resultset('Notification')->search({
  sender_id => $user->id, name => 'response'
  })->count;
  my %data;
  @notifications       = map { $_->as_hashref_sanitized } @notifications;
  $data{total}         = $count_responses;
  $data{notifications} = \@notifications;

  # Le sigh, something stuffed up the serializer plugin.  
  my $json = JSON->new;
  $json->allow_blessed(1);
  $json->convert_blessed(1);
  return $json->encode( \%data);
};

=head2 /api/notification/changed_role/user/:username/page/:page

View page $page of chaged_role notifications for user $username

=cut

get '/api/notification/changed_role/user/:username/page/:page' => sub {

  my $username = route_parameters->{'username'};
  my $page     = route_parameters->{'page'};
  my ( $user ) = resultset('Users')->match_lc( $username );

  my @notifications =
    resultset('Notification')->search(
      { user_id  => $user->id,
        name     => 'changed role' },
      { rows     => config->{api}{notification}{comment}{max_rows},
        page     => $page,
        order_by => { -desc => 'created_date' } }
    );
  my $count_notifications = resultset('Notification')->search({
  user_id => $user->id, name => 'changed role'
  })->count;
  my %data;
  @notifications = map { $_->as_hashref_sanitized } @notifications;
  $data{total}         = $count_notifications;
  $data{notifications} = \@notifications;

  # Le sigh, something stuffed up the serializer plugin.  
  my $json = JSON->new;
  $json->allow_blessed(1);
  $json->convert_blessed(1);
  return $json->encode( \%data);
};
1;
