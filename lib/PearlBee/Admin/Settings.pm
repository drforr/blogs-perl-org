=head1

Author: Andrei Cacio
Email: andrei.cacio@evozon.com

=cut

package PearlBee::Admin::Settings;

use Dancer2;
use Dancer2::Plugin::DBIC;
use PearlBee::Dancer2::Plugin::Admin;

use PearlBee::Helpers::Util qw/generate_crypted_filename/;
use PearlBee::Helpers::Import;

use DateTime::TimeZone;
use POSIX qw(tzset);
use XML::Simple qw(:strict);


=head2 /admin/settings route

Index of settings page

=cut

get '/admin/settings' => sub {

	my $settings  = resultset('Setting')->first;
	my @timezones = DateTime::TimeZone->all_names;
	my @blogs 	  = resultset('Blog')->all();

	template 'admin/settings/index.tt', 
		{ 
			setting   => $settings,
			timezones => \@timezones,
			blogs     => \@blogs
		}, 
		{ layout => 'admin' };
};

=head2 /admin/settings/save

=cut

post '/admin/settings/save' => sub {
	
	my $temp_user = resultset('Users')->find_by_session(session);
	unless ( $temp_user and $temp_user->can_do( 'update settings' ) ) {
		return template 'admin/settings/index.tt', {
			warning => "You are not allowed to update settings",
		}, { layout => 'admin' };
	}
	my $settings;
	my @timezones 	 = DateTime::TimeZone->all_names;
	my $path 	     = params->{path};
	my $social_media = (params->{social_media} ? 1 : 0); # If the social media checkbox isn't checked the value will be undef
	my $timezone  	 = params->{timezone};
	my $multiuser    = (params->{multiuser} ? 1 : 0); # If the multiuser checkbox isn't checked the value will be undef
	my $blog_name 	 = params->{blog_name};

	try {
		$settings = resultset('Setting')->first;

		$settings->update({
			blog_path    => $path,
			timezone     => $timezone,
			social_media => ($social_media ? '1' : '0'),
			multiuser    => ($multiuser ? '1' : '0'),
			blog_name    => $blog_name
		});
	}
	catch {
		error $_;
	};

	template 'admin/settings/index.tt', 
		{ 
			setting   => $settings,
			timezones => \@timezones,
			success   => 'The settings have been saved!'
		}, 
		{ layout => 'admin' };
};

=head2 /admin/settings/import route

=cut

get '/admin/settings/import' => sub {

    template 'admin/settings/import.tt', 
		{}, 
		{ layout => 'admin' };    
};

1;
