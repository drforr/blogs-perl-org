=head

Author: Andrei Cacio
Email: andrei.cacio@evozon.com

=cut

package PearlBee::Admin::User;

use Dancer2;
use Dancer2::Plugin::DBIC;
use PearlBee::Dancer2::Plugin::Admin;

use PearlBee::Helpers::Pagination qw(get_total_pages get_previous_next_link generate_pagination_numbering);
use PearlBee::Helpers::Util qw(create_password);

use Email::Template;
use DateTime;

get '/admin/users' => sub { redirect '/admin/users/page/1'; };

=head2 /admin/users/page/:page

List all users

=cut

get '/admin/users/page/:page' => sub {

  my $nr_of_rows = 5; # Number of posts per page
  my $page       = params->{page} || 1;
  my @users;
  if (session('multiuser')) {
    @users = resultset('Users')->search({}, { order_by => { -desc => "register_date" }, rows => $nr_of_rows, page => $page });
  } else {
    @users = resultset('Users')->search({ status => { '!=' => 'pending' } }, { order_by => { -desc => "register_date" }, rows => $nr_of_rows, page => $page });
  }
  
  my $count = resultset('View::Count::StatusUser')->first;
  
  my ($all, $active, $inactive, $suspended, $pending) = $count->get_all_status_counts;
  
  if (! session('multiuser')) {
    # do not count 'pending' users
    my $count_pending = resultset('Users')->search({ status => 'pending' })->count;
    $all -= $count_pending;
  }

  # Calculate the next and previous page link
  my $total_pages                 = get_total_pages($all, $nr_of_rows);
  my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, '/admin/users');

  # Generation of the pagination navigation
  my $total_users    = $all;
  my $posts_per_page = $nr_of_rows;
  my $current_page   = $page;
  my $pages_per_set  = 7;
  my $pagination     = generate_pagination_numbering($total_users, $posts_per_page, $current_page, $pages_per_set);

  template 'admin/users/list',
    {
      users         => \@users,
      all           => $all, 
      active        => $active,
      inactive      => $inactive,
      suspended     => $suspended,
      pending       => $pending,
      page          => $page,
      next_link     => $next_link,
      previous_link => $previous_link,
      action_url    => 'admin/users/page',
      pages         => $pagination->pages_in_set
    },
    { layout => 'admin' };

};

=head2 /admin/users/:status/page/:page

List all users grouped by status

=cut

get '/admin/users/:status/page/:page' => sub {

  my $nr_of_rows = 5; # Number of posts per page
  my $page       = params->{page} || 1;
  my $status     = params->{status};
  my @users      = resultset('Users')->search({ status => $status }, { order_by => { -desc => "register_date" }, rows => $nr_of_rows, page => $page });
  my $count      = resultset('View::Count::StatusUser')->first;
  
  my ($all, $active, $inactive, $suspended, $pending) =
    $count->get_all_status_counts;
  my $status_count =
    $count->get_status_count($status);
  
  if (! session('multiuser')) {
    # do not count 'pending' users
    my $count_pending = resultset('Users')->search({ status => 'pending' })->count;
    $all -= $count_pending;
  }

  # Calculate the next and previous page link
  my $total_pages                 = get_total_pages($all, $nr_of_rows);
  my ($previous_link, $next_link) = get_previous_next_link($page, $total_pages, '/admin/users/' . $status);

  # Generating the pagination navigation
  my $total_users     = $status_count;
  my $posts_per_page  = $nr_of_rows;
  my $current_page    = $page;
  my $pages_per_set   = 7;
  my $pagination      = generate_pagination_numbering($total_users, $posts_per_page, $current_page, $pages_per_set);

  template 'admin/users/list',
    {
      users         => \@users,
      all           => $all, 
      active        => $active,
      inactive      => $inactive,
      suspended     => $suspended,
      pending       => $pending,
      page          => $page,
      next_link     => $next_link,
      previous_link => $previous_link,
      action_url    => 'admin/users/' . $status . '/page',
      pages         => $pagination->pages_in_set,
      status        => $status
    },
    { layout => 'admin' };

};

=head2 /admin/users/activate/:id

Activate user

=cut

any '/admin/users/activate/:id' => sub {

  my $user_id = params->{id};
  my $user    = resultset('Users')->find( $user_id );

  try {
    $user->activate();
  }
  catch {
    info $_;
    error "Could not activate user";
  };

  redirect '/admin/users';
};

=head2 /admin/users/deactivate/:id

Deactivate user

=cut

any '/admin/users/deactivate/:id' => sub {

  my $user_id          = params->{id};
  my $user             = resultset('Users')->find( $user_id );
  my $admin_user_count = resultset('Users')->search({ role => 'admin' })->count;

  if ( $user->is_admin and
       $admin_user_count <= 1 ) {
      error "Could not deactivate the only active user";
  }
  else {
    try {
      $user->deactivate();
    }
    catch {
      info $_;
      error "Could not deactivate user";
    };
  }

  redirect '/admin/users';
};

=head2 /admin/users/suspend/:id

Suspend user

=cut

any '/admin/users/suspend/:id' => sub {

  my $user_id          = params->{id};
  my $user             = resultset('Users')->find( $user_id );
  my $admin_user_count = resultset('Users')->search({ role => 'admin' })->count;

  if ( $user->is_admin and
       $admin_user_count <= 1 ) {
      error "Could not suspend the only active user";
  }
  else {
    try {
      $user->suspend();
    }
    catch {
      info $_;
      error "Could not mark comment as pending for $user->{username}";
    };
  }

  redirect '/admin/users';
};

=head2 /admin/users/allow/:id

Allow pending user

=cut

any '/admin/users/allow/:id' => sub {

  my $user_id = params->{id};
  my $user    = resultset('Users')->find( $user_id );
  
  if ($user) {
    try {
      my $hashed_password = create_password();
      
      $user->update({ password => $hashed_password });
    
      $user->allow();
      
      Email::Template->send( config->{email_templates} . 'welcome.tt',
          {
              From    => config->{default_email_sender},
              To      => $user->email,
              Subject => config->{welcome_email_subject},
  
              tt_vars => {
                  role      => $user->role,
                  username  => $user->username,
                  password  => $hashed_password,
                  name      => $user->name,
                  app_url   => config->{app_url},
                  blog_name => session('blog_name'),
                  signature => config->{email_signature},
                  allowed   => 1,
              },
          });
    }
    catch {
      info "Error sending email: $_";
      error "Could not send the email";
    };
  }

  redirect '/admin/users';
};

=head2 /admin/users/add

Add a new user

=cut

any '/admin/users/add' => sub {

  if ( params->{username} ) {

    try {

      my $username = params->{username};
      my $email    = params->{email};
      my $name     = params->{name};
      my $role     = params->{role};

      resultset('Users')->create_hashed({
        username => $username,
        password => params->{password},
        name     => $name,
        role     => $role,
        email    => $email,
      });

      Email::Template->send( config->{email_templates} . 'welcome.tt',
        {
            From    => config->{default_email_sender},
            To      => $email,
            Subject => config->{welcome_email_subject},

            tt_vars => {
                role      => $role,
                username  => $username,
        	password  => params->{password},
                name      => $name,
                app_url   => config->{app_url},
                blog_name => session('blog_name'),
                signature => config->{email_signature}
            },
        }) or error "Could not send the email";
    }
    catch {
      error $_;
      template 'admin/users/add', 
        {
          warning => 'Something went wrong. Please contact the administrator.'
        }, 
        { layout => 'admin' };
    };

    template 'admin/users/add', 
      {
      success => 'The user was added succesfully and will be activated after he logs in.'
      }, 
      { layout => 'admin' };
  }
  else {
    template 'admin/users/add', {},  { layout => 'admin' };
  }  
};

1;
