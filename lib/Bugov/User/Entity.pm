package Bugov::User::Entity;
use Mojo::Base 'Bugov::User::UserMixin';

has 'id';
has 'username';
has 'email';
has 'role';

sub init {
  my ($self, %params) = @_;
  $self->$_($params{$_}) for keys %params;
  return $self;
}

1;