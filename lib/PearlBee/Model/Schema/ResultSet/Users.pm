package  PearlBee::Model::Schema::ResultSet::Users;

use strict;
use warnings;

use Dancer2;
use Dancer2::Plugin::DBIC;
use PearlBee::Model::Schema;
use base 'DBIx::Class::ResultSet';

=head2 find_by_session(session)

Search for a user via session

=cut

sub find_by_session {
  my ($self,$session) = @_;
  my $schema          = $self->result_source->schema;
  if ( $session->{data}{user} ) {
    my $user            = $session->{'data'}{'user'};
  
    return $schema->resultset('Users')->find({ username => $user->{username} });
  }
  return;
}

=head2 search_lc

Search for a username case-insensitive

=cut

sub search_lc {
  my ($self, $username) = @_;
  my $schema            = $self->result_source->schema;
  
  my $lc_username = lc $username;
  return $schema->resultset('Users')->
                  search( \[ "lower(username) like '\%$lc_username\%' or
                              lower(name) like '\%$lc_username\%'" ] );

}

=head2 match_lc

=cut

sub match_lc {
  my ($self, $username) = @_;
  my $schema            = $self->result_source->schema;
  
  my $lc_username = lc $username;
  return $schema->resultset('Users')->
                  search( \[ "lower(username) = '$lc_username'" ] );
}


=head2 create_hashed

Create user with pre-hashed password

=cut

sub create_hashed {
  my ($self, $args) = @_;
  my $schema = $self->result_source->schema;
  my @alpha  = ( 'a' .. 'z', 'A' .. 'Z', 0 .. 9 );
  my $salt   = join '', map $alpha[ rand @alpha ], 1 .. 16;
  my $algo   = '$6$' . $salt . '$';
  my $hashed = crypt( $args->{password}, $algo );

  $schema->resultset('Users')->create({
    username       => $args->{username},
    password       => $hashed,
    email          => $args->{email},
    name           => $args->{name},
    role           => $args->{role},
    status         => $args->{status},
    activation_key => $args->{activation_key}
  });
}

=head2 create_hashed_with_blog

=cut

sub create_hashed_with_blog {
  my ($self, $args) = @_;
  my $schema = $self->result_source->schema;
  my $user   = $schema->resultset('Users')->create_hashed( $args );
  my $blog   = $schema->resultset('Blog')->create_with_slug({
    name        => config->{blogs}{default_name},
    description => config->{blogs}{default_description},
  });

  $schema->resultset('BlogOwner')->create({
    blog_id  => $blog->id,
    user_id  => $user->id,
    is_admin =>"true",
  });
}

1;
