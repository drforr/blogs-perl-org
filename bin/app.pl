#!/usr/bin/env perl

use Config::Any;
use FindBin;
use Term::ANSIColor;
use lib "$FindBin::Bin/../lib";

use constant WHITE_ON_RED => 'white on_red';

chdir("$FindBin::Bin/../");

use PearlBee;

my $cfg = Config::Any->load_stems({
  stems   => [ 'config' ],
  use_ext => 1
});
$cfg = $cfg->[0];
$cfg = $cfg->{(keys %$cfg)[0]};

my $error = 0;
$error++ unless -e 'public/avatars';
$error++ unless -e 'public/userpics';
for my $plugin ( qw( mail_server ) ) {
  for ( qw( user password host ) ) {
    $error++ unless $cfg->{$plugin}{$_};
  }
}
for my $plugin ( qw( reCAPTCHA ) ) {
  for ( qw( client_id secret ) ) {
    $error++ unless $cfg->{plugins}{$plugin}{$_};
  }
}
for my $plugin ( qw( facebook twitter google github linkedin ) ) {
  for ( qw( client_id secret ) ) {
    $error++ unless $cfg->{plugins}{social_media}{$plugin}{$_};
  }
}

sub warn_missing {
  my ( $message ) = @_;
  my $color = WHITE_ON_RED;

  warn colored($message, $color) . "\n";
}

sub warn_missing_secret {
  my ( $name, $config ) = @_;

  warn_missing("Missing " . $name . " site key") unless $config->{site_key};
  warn_missing("Missing " . $name . " secret") unless $config->{secret};
}

if ( $error ) {
  warn_missing("###################################");

  my $color = WHITE_ON_RED;
  -e 'public/avatars' or
    warn colored("Missing public/avatars/ symlink - run '",$color) .
      q{ln -s ~/avatars public/avatars'} .
      colored(q{'},$color);
  -e 'public/userpics' or
    warn colored("Missing public/userpics/ symlink - run '",$color) .
      q{ln -s ~/userpics public/userpics'} .
      colored(q{'},$color);

  my $mail_server = $cfg->{mail_server};
  $mail_server->{user}     or warn_missing("Missing mail server user");
  $mail_server->{password} or warn_missing("Missing mail server password");
  $mail_server->{host}     or warn_missing("Missing mail server host");

  warn_missing_secret( 'reCAPTCHA', $cfg->{plugins}{reCAPTCHA}              );
  warn_missing_secret( 'facebook',  $cfg->{plugins}{social_media}{facebook} );
  warn_missing_secret( 'twitter',   $cfg->{plugins}{social_media}{twitter}  );
  warn_missing_secret( 'google',    $cfg->{plugins}{social_media}{google}   );
  warn_missing_secret( 'github',    $cfg->{plugins}{social_media}{github}   );
  warn_missing_secret( 'linkedin',  $cfg->{plugins}{social_media}{linkedin} );

  warn colored("###################################",$color)."\n";
}

PearlBee->dance;
