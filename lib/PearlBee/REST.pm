package PearlBee::REST;

use Dancer2;
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::REST;

prepare_serializer_for_format;

=head2 /api/tags.:format route

Get an array with all tags

=cut

get '/api/tags.:format' => sub {  
	my $user  = resultset('Users')->find_by_session(session);

	if ($user) {
		my @tags = resultset('Tag')->all;
		my @list = map { $_->name } @tags;

		return \@list;
	}
};

=head2 /api/categories.:format route

Get an array with all categories

=cut

get '/api/categories.:format' => sub {
  
	my $user         = resultset('Users')->find_by_session(session);

	if ($user) {
		my @categories = resultset('Category')->all;
		my @list = map { $_->name } @categories;

		return \@list;
	}
};

1;
