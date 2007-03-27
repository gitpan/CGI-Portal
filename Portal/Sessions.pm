package CGI::Portal::Sessions;
# Copyright (c) 2005 Alexander David. All rights reserved.

use strict;
use Digest::MD5 qw(md5_hex);
use vars qw($VERSION);
$VERSION = "0.04";

1;

sub new {
  my ($class, $i) = @_;
  bless $i, $class;
  return $i;
}

sub authenticate_user {
  my $self = shift;
  my $template = HTML::Template->new(filename => "$self->{'conf'}{'template_dir'}Sessions.html");
  $template->param(SCRIPT_NAME => $ENV{'SCRIPT_NAME'});
  if ($self->{'in'}{'user'} && $self->{'in'}{'password'}){
    my $users = $self->{'rdb'}->exec("select $self->{'conf'}{'user_user_field'},$self->{'conf'}{'user_passw_field'} from $self->{'conf'}{'user_table'} where $self->{'conf'}{'user_user_field'} like " . $self->{'rdb'}->escape($self->{'in'}{'user'}))->fetch;
    if (md5_hex($self->{'in'}{'password'}) eq $users->[1]){
      $self->{'user'} = $users->[0];
      $self->start_session($users->[0]);
      $self->clean_sessions();
      return;
    }
  }elsif (my $sid = getcookie('sid')){
    my $exps = time() - $self->{'conf'}{'session_length'};
    my $sessions = $self->{'rdb'}->exec("select $self->{'conf'}{'session_user_field'},$self->{'conf'}{'session_start_field'} from $self->{'conf'}{'session_table'} where $self->{'conf'}{'session_sid_field'}=" . $self->{'rdb'}->escape($sid))->fetch;
    if ($sessions->[0] && $sessions->[1] >= $exps){
      $self->{'user'} = $sessions->[0];
      $self->renew_session($self->{'user'});
      return;
    }
  }
  $self->{'out'} = $template->output;
}

sub start_session {
  my ($self, $user) = @_;
  my $current_time = time();
  my $sid = md5_hex($$ , time() , rand(9999) );
  my $cc = $self->{'rdb'}->exec("select $self->{'conf'}{'session_index_field'} from $self->{'conf'}{'session_table'} order by $self->{'conf'}{'session_index_field'} desc limit 1")->fetch;
  my $c = $cc->[0]+1;
  $self->{'rdb'}->exec("insert into $self->{'conf'}{'session_table'} ($self->{'conf'}{'session_index_field'},$self->{'conf'}{'session_sid_field'},$self->{'conf'}{'session_user_field'},$self->{'conf'}{'session_start_field'}) values (" . $self->{'rdb'}->escape($c, $sid, $user, $current_time) . ")");
  $self->{'cookies'} .= "Set-Cookie: sid=$sid; path=/\n";
}

sub renew_session {
  my $self = shift;
  my $sid = getcookie('sid');
  my $current_time = time();
  $self->{'rdb'}->exec("update $self->{'conf'}{'session_table'} set $self->{'conf'}{'session_start_field'}=$current_time where $self->{'conf'}{'session_sid_field'}=" . $self->{'rdb'}->escape($sid));
}

sub logoff {
  my $self = shift;
  my $sid = getcookie('sid');
  $self->{'rdb'}->exec("delete from $self->{'conf'}{'session_table'} where $self->{'conf'}{'session_sid_field'}=" . $self->{'rdb'}->escape($sid));
  $self->{'user'} = "";
}

sub clean_sessions {
  my $self = shift;
  my $exps = time() - $self->{'conf'}{'session_length'};
  $self->{'rdb'}->exec("delete from $self->{'conf'}{'session_table'} where $self->{'conf'}{'session_start_field'} < $exps");
}

sub getcookie {
  my $cookiename = shift;
  my $cookie;
  my $value;
  if ($ENV{'HTTP_COOKIE'}) {
    foreach (split(/; /,$ENV{'HTTP_COOKIE'})) {
      ($cookie,$value) = split(/=/);
      if ($cookiename eq $cookie) {
        return $value;
      }
    }
  }
}