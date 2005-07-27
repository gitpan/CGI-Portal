package CGI::Portal::Scripts::changepw;
# Copyright (c) 2005 Alexander David. All rights reserved.

use strict;
use Digest::MD5 qw(md5_hex);
use CGI::Portal::Sessions;
use vars qw(@ISA $VERSION);
$VERSION = "0.02";

@ISA = qw(CGI::Portal::Sessions);

my %input_fields;
my $passw;

1;

sub launch {
  my $self = shift;
  $self->authenticate_user();
  if ($self->{'user'}){
    $self->input_html();
    if ($self->{'in'}{'submit'}){
      my $users = $self->{'rdb'}->exec("select $self->{'conf'}{'user_passw_field'} from $self->{'conf'}{'user_table'} where $self->{'conf'}{'user_user_field'}=" . $self->{'rdb'}->escape($self->{'user'}) . " limit 1")->fetch;
      $passw = $users->[0];
      unless ($self->input_error("chpss","cchpss","passw")){
        my $enc_passw = md5_hex($self->{'in'}{'chpss'});
        $self->{'rdb'}->exec("update $self->{'conf'}{'user_table'} set $self->{'conf'}{'user_passw_field'}=\'$enc_passw\' where $self->{'conf'}{'user_user_field'}=" . $self->{'rdb'}->escape($self->{'user'}));
      }
    }
    $self->{'out'} = $self->html_form();
  }
}

sub input_html {
  my $self = shift;
  $input_fields{'passw'} = "<input type=password name=passw size=64>";
  $input_fields{'chpss'} = "<input type=password name=chpss size=64>";
  $input_fields{'cchpss'} = "<input type=password name=cchpss size=64>";
}

sub input_error {
  my $self = shift;
  my $input_error = 0;
  my @requireds = @_;
  foreach my $required (@requireds){
    if (!$self->{'in'}{$required}){
      $input_fields{$required} .= " Field is required";
      $input_error = 1;
    }
  }
  if ($self->{'in'}{'passw'} &&  md5_hex($self->{'in'}{'passw'}) ne $passw){$input_fields{'passw'} .= " Incorrect Password";
      $input_error = 1;}
  if ($self->{'in'}{'chpss'} && $self->{'in'}{'chpss'} !~ /..../i){$input_fields{'chpss'} .= " Passwords must consist of at least 4 characters";
      $input_error = 1;}
  if ($self->{'in'}{'cchpss'} && $self->{'in'}{'chpss'} ne $self->{'in'}{'cchpss'}){$input_fields{'cchpss'} .= " Please reenter and confirm password";
      $input_error = 1;}
  return $input_error;
}

sub html_form {
  my $self = shift;
  return <<EOF;
<form  method=post>
<table>
</TD></TR><TR><TD>
Current Password<br>
</TD><TD>
$input_fields{'passw'}
</TD></TR><TR><TD>
New Password
</TD><TD>
$input_fields{'chpss'}
</TD></TR><TR><TD>
Confirm Password
</TD><TD>
$input_fields{'cchpss'}
</TD></TR><TR><TD colspan=2>
<input type="hidden" name="action" value="changepw">
<CENTER>
<input type="submit" name="submit" value="Submit">&nbsp;&nbsp;<input type="reset" value="Reset" name="reset">
</CENTER>
</TD></TR></TABLE></form>
EOF
}