=head

Author: Andrei Cacio
Email: andrei.cacio@evozon.com

=cut

package PearlBee::Admin::Category;

use Try::Tiny;
use Dancer2;

use Dancer2::Plugin::DBIC;
use PearlBee::Dancer2::Plugin::Admin;

use PearlBee::Helpers::Util qw(string_to_slug);

=head2 /admin/categories

list all categories

=cut

get '/admin/categories' => sub {
  my @categories = resultset('Category')->search({ name => { '!=' => 'Uncategorized'} });

  template 'admin/categories/list', { categories => \@categories }, { layout => 'admin' };
};

=head2 /admin/categories/add

create method

=cut

post '/admin/categories/add' => sub {

  my @categories;
  my $name   = params->{name};
  my $slug   = params->{slug};
  my $params = {};

  $slug = string_to_slug($slug);

  my $found_slug_or_name = resultset('Category')->search({ -or => [ slug => $slug, name => $name ] })->first;

  if ( $found_slug_or_name ) {
    @categories = resultset('Category')->search({ name => { '!=' => 'Uncategorized'} });

    $params->{warning} = "The category name or slug already exists";
  }
  else {
    try {
      my $user     = session('user');
      my $category = resultset('Category')->create({
          name    => $name,
          slug    => $slug,
          user_id => $user->{id}
      });
    }
    catch {
      error "Could not create category '$name'";
    };

    $params->{success} = "The cateogry was successfully added.";
  }

  @categories = resultset('Category')->search({ name => { '!=' => 'Uncategorized'} });
  $params->{categories} = \@categories;

  template 'admin/categories/list', $params, { layout => 'admin' };

};

=head2 /admin/categories/delete/:id

delete method

=cut

get '/admin/categories/delete/:id' => sub {

  my $id = params->{id};

  try {
    my $category = resultset('Category')->find( $id );

    $category->safe_cascade_delete();
  }
  catch {
    error $_;
    my @categories = resultset('Category')->search({ name => { '!=' => 'Uncategorized'} });

    template 'admin/categories/list', { categories => \@categories, warning => "Something went wrong." }, { layout => 'admin' };
  };

  redirect "/admin/categories";

};

=head2 /admin/categories/edit/:id

edit method

=cut

any '/admin/categories/edit/:id' => sub {

  my $category_id = params->{id};
  my $name        = params->{name};
  my $slug        = params->{slug};
  my $category    = resultset('Category')->find( $category_id );
  my @categories;
  my $params = {};

  # Check if the form was submited
  if ( $name && $slug ) {

    $slug = string_to_slug($slug);

    my $found_slug = resultset('Category')->search({ id => { '!=' => $category->id }, slug => $slug })->first;
    my $found_name = resultset('Category')->search({ id => { '!=' => $category->id }, name => $name })->first;

    # Check if the user entered an existing slug
    if ( $found_slug ) {

      $params->{warning} = 'The category slug already exists';

    }
    # Check if the user entered an existing name
    elsif ( $found_name ) {

      $params->{warning} = 'The category name already exists';

    }
    else {
      eval {
        $category->update({
            name => $name,
            slug => $slug
          });
      };

      $params->{success} = 'The category was updated successfully'
    }
  }

  @categories = resultset('Category')->search({ name => { '!=' => 'Uncategorized'} });

  $params->{category}   = $category;
  $params->{categories} = \@categories;
  
  # If the form wasn't submited just list the categories
  template 'admin/categories/list', $params, { layout => 'admin' };


};

1;
