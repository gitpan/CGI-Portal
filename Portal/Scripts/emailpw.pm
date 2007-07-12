package CGI::Portal::Scripts::emailpw;
# Copyright (c) 2005 Alexander David. All rights reserved.

use strict;
use Digest::MD5 qw(md5_hex);
use CGI::Portal::Sessions;
use vars qw(@ISA $VERSION);
$VERSION = "0.08";

@ISA = qw(CGI::Portal::Sessions);

1;

sub launch {
  my $self = shift;
  my $template = HTML::Template->new(filename => "$self->{'conf'}{'template_dir'}emailpw.html");
  $template->param(SCRIPT_NAME => $ENV{'SCRIPT_NAME'});
  if ($self->{'in'}{'usr'}){
    my $r = $self->{'rdb'}->exec("select $self->{'conf'}{'user_additional'}[0],$self->{'conf'}{'user_user_field'} from $self->{'conf'}{'user_table'} where $self->{'conf'}{'user_user_field'} like " . $self->{'rdb'}->escape($self->{'in'}{'usr'}) . " limit 1")->fetch;
    if ($r->[0] =~ /.*@.*\./){
      my $pw = substr(md5_hex(rand(64)), 1, 9);
      my $enc_pw = md5_hex($pw);
      $self->{'rdb'}->exec("update $self->{'conf'}{'user_table'} set $self->{'conf'}{'user_passw_field'}=\'$enc_pw\' where $self->{'conf'}{'user_user_field'}=" . $self->{'rdb'}->escape($r->[1]));
      mailit($r->[0],$self->{'conf'}{'admin_email'},"Logon Info ","Please use $pw to log on, and choose a new password at your convenience.");
      $self->{'out'} = "A temporary password has been emailed to you.";
    }
    elsif (! $r->[0] ){
      $template->param(HOME => "Unknown User");
      $self->{'out'} = $template->output;
    }else{
      $self->{'out'} = "Invalid email on record, please contact us.";
    }
  }else{
    $self->{'out'} = $template->output;
  }
}

sub mailit {
  my $recipient = shift;
  my $sender = shift;
  my $subject = shift;
  my $message = shift;
  open(MAIL, "|/usr/lib/sendmail -t");
  print MAIL "To: $recipient\n";
  print MAIL "From: $sender\n";
  print MAIL "Subject: $subject\n\n";
  print MAIL "$message";
  close (MAIL);
}