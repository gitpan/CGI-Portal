package CGI::Portal::Scripts::emailpw;
# Copyright (c) 2005 Alexander David. All rights reserved.

use strict;
use Digest::MD5 qw(md5_hex);
use CGI::Portal::Sessions;
use vars qw(@ISA $VERSION);
$VERSION = "0.02";

@ISA = qw(CGI::Portal::Sessions);

1;

sub launch {
  my $self = shift;
  my $programs;
  if ($self->{'in'}{'usr'}){
    my $r = $self->{'rdb'}->exec("select $self->{'conf'}{'user_email_field'},$self->{'conf'}{'user_user_field'} from $self->{'conf'}{'user_table'} where $self->{'conf'}{'user_user_field'} like " . $self->{'rdb'}->escape($self->{'in'}{'usr'}) . " limit 1")->fetch;
    if ($r->[0] =~ /.*@.*\./){
      my $pw = substr(md5_hex(rand(64)), 1, 9);
      my $enc_pw = md5_hex($pw);
      $self->{'rdb'}->exec("update $self->{'conf'}{'user_table'} set $self->{'conf'}{'user_passw_field'}=\'$enc_pw\' where $self->{'conf'}{'user_user_field'}=" . $self->{'rdb'}->escape($r->[1]));
      mailit($r->[0],$self->{'conf'}{'admin_email'},"Logon Info ","Please use $pw to log on, and choose a new password at your convenience.");
      $self->{'out'} = "A temporary password has been emailed to you.";
    }
    elsif (! $r->[0] ){
      $programs .= $self->html_form("Unknown User");
    }else{
      $programs .= "Invalid email on record, please contact us.";
    }
  }else{
    $programs .= $self->html_form();
  }
  $self->{'out'} = $programs;
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

sub html_form {
  my $self = shift;
  my $ro = shift;
  return <<EOF;
<form method="post" action="$ENV{'SCRIPT_NAME'}?action=logon">
<table>
<tr>
<td colspan="2" align="center">
$ro&nbsp;
</td>
</tr>
<tr>
<td><strong>Username:</strong></td>
<td>
<input type="text" name="usr" size="25">
</td>
</tr>
<tr align="center">
<td colspan="2">
<input type="hidden" name="action" value="emailpw">
<input type="submit" name="submit" value="Reset my password">
</td>
</tr>
</table>
</form>
EOF
}