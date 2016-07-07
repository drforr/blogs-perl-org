package PearlBee::Model::Schema::ResultSet::Notification;

use strict;
use warnings;

use DateTime;
use Dancer2;
use Dancer2::Plugin::DBIC;
use PearlBee::Model::Schema;
use base 'DBIx::Class::ResultSet';


=head2 create_comment({ comment_id => 1, user_id => 1, sender_id => 1 })

Create comment notification

=cut

sub create_comment {
  my ($self, $args) = @_;
  my $schema = $self->result_source->schema;

  $schema->resultset('Notification')->create({
    name       => 'comment',
    viewed     => 0,
    generic_id => $args->{comment_id},
    sender_id  => $args->{sender_id},
    user_id    => $args->{user_id}
  });
}


=head2 read_comment({ comment_id => 1, user_id => 1 })

Read comment notification

=cut

sub read_comment {
  my ($self, $args) = @_;
  my $schema = $self->result_source->schema;

  my $now = DateTime->now;
  my $notification = $schema->resultset('Notification')->find({
    name       => 'comment',
    generic_id => $args->{comment_id},
    user_id    => $args->{user_id}
  });
  if ( $notification ) {
    $notification->update({ viewed => 1, read_date => $now });
  }
}


=head2 create_invitation({ blog_id => 1, role => 'author', user_id => 1, sender_id })

Create invitation notification

=cut

sub create_invitation {
  my ($self, $args) = @_;
  my $schema = $self->result_source->schema;

  $schema->resultset('Notification')->create({
    name       => 'invitation',
    generic_id => $args->{blog_id},
    role       => $args->{role},
    sender_id  => $args->{sender_id},
    user_id    => $args->{user_id}
  });
}


=head2 read_invitation({ blog_id => 1, user_id => 1 })

Read invitation notification

=cut

sub read_invitation {
  my ($self, $args) = @_;
  my $schema = $self->result_source->schema;

  my $now = DateTime->now;
  my $notification = $schema->resultset('Notification')->find({
    name       => 'invitation',
    generic_id => $args->{blog_id},
    user_id    => $args->{user_id}
  });
  if ( $notification ) {
    $notification->update({ viewed => 1, read_date => $now });
  }
}


=head2 create_response({ blog_id => 1, user_id => 1, sender_id => 1 })

Create response notification

=cut

sub create_response {
  my ($self, $args) = @_;
  my $schema = $self->result_source->schema;

  $schema->resultset('Notification')->create({
    name       => 'response',
    generic_id => $args->{blog_id},
    sender_id  => $args->{sender_id},
    user_id    => $args->{user_id}
  });
}


=head2 read_response({ blog_id => 1, user_id => 1 })

Read response notification

=cut

sub read_response {
  my ($self, $args) = @_;
  my $schema = $self->result_source->schema;

  my $now = DateTime->now;
  my $notification = $schema->resultset('Notification')->find({
    name       => 'response',
    generic_id => $args->{blog_id},
    user_id    => $args->{user_id}
  });
  if ( $notification ) {
    $notification->update({ viewed => 1, read_date => $now });
  }
}


=head2 create_changed_role({ old_role => 'author', user_id => 1, sender_id => 1 })

Create changed_role notification

=cut

sub create_changed_role {
  my ($self, $args) = @_;
  my $schema = $self->result_source->schema;

  $schema->resultset('Notification')->create({
    name       => 'changed_role',
    old_status => $args->{old_role},
    sender_id  => $args->{sender_id},
    user_id    => $args->{user_id}
  });
}


=head2 read_changed_role({ old_role => 'author', user_id => 1 })

Read changed_role notification

=cut

sub read_changed_role {
  my ($self, $args) = @_;
  my $schema = $self->result_source->schema;

  my $now = DateTime->now;
  my $notification = $schema->resultset('Notification')->find({
    name       => 'changed_role',
    old_status => $args->{old_role},
    user_id    => $args->{user_id}
  });
  if ( $notification ) {
    $notification->update({ viewed => 1, read_date => $now });
  }
}


1;
