package Bugov::User;
use Mojo::Base 'Mojolicious::Plugin::Module::Abstract';
use Mojo::ByteStream;
use Bugov::User::Entity;

sub init_routes {
  my ($self, $app) = @_;
  my $r = $app->routes;
  
  # Access
  my $user  = $r->bridge('/user' )->to(cb => sub {my $self = shift; $self->user->is_user () ? 1 : $self->redirect_to('user_login') && 0});
  my $staff = $r->bridge('/staff')->to(cb => sub {my $self = shift; $self->user->is_staff() ? 1 : $self->redirect_to('user_login') && 0});
  my $admin = $r->bridge('/admin')->to(cb => sub {my $self = shift; $self->user->is_admin() ? 1 : $self->redirect_to('user_login') && 0});
  
  my $u = $r->route('user')->to('user#', namespace => 'Bugov::User::Controller');
    $u->get ('login') ->to('#login_form')->name('user_login_form');
    $u->post('login') ->to('#login')     ->name('user_login');
    $u->get ('reg')   ->to('#reg_form')  ->name('user_reg_form');
    $u->post('reg')   ->to('#reg')       ->name('user_reg');
  $u = $user->to('user#', namespace => 'Bugov::User::Controller');
    $u->get ('home')  ->to('#home')  ->name('user_home');
    $u->get ('logout')->to('#logout')->name('user_logout');
  $u = $admin->route('user')->to('user#', namespace => 'Bugov::User::Controller::Admin');
    $u->get ('list/:page')->to('#list', page => 1)->name('admin_user_list');
    $u->get (':id')->to('#show')->name('admin_user_show');
    $u->post(':id')->to('#edit')->name('admin_user_edit');
}

sub init_helpers {
  my ($self, $app) = @_;
  
  # User session getter
  $app->helper(user => sub {
    my $self = shift;
    return Bugov::User::Entity->new->init(
      id       => $self->session('id'),
      username => $self->session('username'),
      email    => $self->session('email'),
      role     => $self->session('role'),
    );
  });
  
  # select user (html)
  $app->helper(user_list => sub {
    my ($self, $role, $default, $html_name) = @_;
    $role = $self->user->roles->{$role};
    my $user_list = Bugov::User::Model::User::Manager->get_users(where => [role => {ge => $role}]);
    
    return Mojo::ByteStream->new($self->render(
      'user/helper/user_list',
      partial   => 1,
      default   => int $default,
      user_list => $user_list,
      html_name => $html_name
    ));
  });
  
  # select role (html)
  $app->helper(role_list => sub {
    my ($self, $default) = @_;
    
    return Mojo::ByteStream->new($self->render(
      'user/helper/role_list',
      partial   => 1,
      role_list => $self->user->roles,
      default   => int $default
    ));
  });
}

1;