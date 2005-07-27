package CGI::Portal::Scripts::register;
# Copyright (c) 2005 Alexander David. All rights reserved.

use strict;
use Digest::MD5 qw(md5_hex);
use CGI::Portal::Scripts::logon;
use CGI::Portal::Sessions;
use vars qw(@ISA $VERSION);
$VERSION = "0.02";

@ISA = qw(CGI::Portal::Sessions);

my %input_fields;

1;

sub launch {
  my $self = shift;
  $self->input_html();
  if ($self->{'in'}{'submit'}){
    unless ($self->input_error("user","password","cpassw","email")){
      my $cc = $self->{'rdb'}->exec("select $self->{'conf'}{'user_index_field'} from $self->{'conf'}{'user_table'} order by $self->{'conf'}{'user_index_field'} desc limit 1")->fetch;
      my $c = $cc->[0]+1;
      my $enc_passw = md5_hex($self->{'in'}{'password'});
      my $values = $self->{'rdb'}->escape($c,$self->{'in'}{'user'},$enc_passw,$self->{'in'}{'email'},$self->{'in'}{'first_name'},$self->{'in'}{'middle_initial'},$self->{'in'}{'last_name'},$self->{'in'}{'city'},$self->{'in'}{'state'},$self->{'in'}{'country'});
      $self->{'rdb'}->exec("insert into $self->{'conf'}{'user_table'} ($self->{'conf'}{'user_index_field'},$self->{'conf'}{'user_user_field'},$self->{'conf'}{'user_passw_field'},$self->{'conf'}{'user_email_field'},$self->{'conf'}{'add_user_fields'}) values ($values)");
      $self->{'user'} = $self->{'in'}{'user'};
      bless $self, "CGI::Portal::Scripts::logon";
      $self->launch;
      return;
    }
  }
  $self->{'out'} = $self->html_form();
}

sub input_html {
  my $self = shift;
  my @states = qw(Other AL AK AZ AR CA CO CT DC DE FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VA VT WA WV WI WY);
  $input_fields{'user'} = "<input type=text name=user size=64  value=\"$self->{'in'}{'user'}\">";
  $input_fields{'password'} = "<input type=password name=password size=64  value=\"\">";
  $input_fields{'cpassw'} = "<input type=password name=cpassw size=64  value=\"\">";
  $input_fields{'email'} = "<input type=text name=email size=64  value=\"$self->{'in'}{'email'}\">";
  $input_fields{'first_name'} = "<input type=text name=first_name size=64  value=\"$self->{'in'}{'first_name'}\">";
  $input_fields{'middle_initial'} = "<input type=text name=middle_initial size=4  value=\"$self->{'in'}{'middle_initial'}\">";
  $input_fields{'last_name'} = "<input type=text name=last_name size=64  value=\"$self->{'in'}{'last_name'}\">";
  $input_fields{'city'} = "<input type=text name=city size=64  value=\"$self->{'in'}{'city'}\">";
  $input_fields{'state'} = "<select name=state>";
  foreach my $s (@states){
    if ($s ne $self->{'in'}{'state'}){
      $input_fields{'state'} .=  "<option>$s";
    }else{
      $input_fields{'state'} .=  "<option selected>$s";
    }
  }
  $input_fields{'state'} .= "</select>";
  $input_fields{'country'} .= "<input type=text name=country size=64  value=\"$self->{'in'}{'country'}\">";
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
  my $r = $self->{'rdb'}->exec("select $self->{'conf'}{'user_index_field'} from $self->{'conf'}{'user_table'} where $self->{'conf'}{'user_user_field'} like " . $self->{'rdb'}->escape($self->{'in'}{'usr'}) . " limit 1")->fetch;
  if ($r->[0]){$input_fields{'user'} .= " User name $self->{'in'}{'user'} is not available";
      $input_error = 1;}
  if ($self->{'in'}{'user'} && $self->{'in'}{'user'} =~ /[^\w ]/i){$input_fields{'user'} .= " User names must consist of letters or numbers";
      $input_error = 1;}
  if ($self->{'in'}{'user'} && $self->{'in'}{'user'} =~ / /i){$input_fields{'user'} .= " User names cannot contain spaces";
      $input_error = 1;}
  if ($self->{'in'}{'user'} && $self->{'in'}{'user'} =~ /................/i){$input_fields{'user'} .= " User names must consist of less than 16 characters";
      $input_error = 1;}
  if ($self->{'in'}{'password'} && $self->{'in'}{'password'} !~ /..../i){$input_fields{'password'} .= " Passwords must consist of at least 4 characters";
      $input_error = 1;}
  if ($self->{'in'}{'cpassw'} && $self->{'in'}{'password'} ne $self->{'in'}{'cpassw'}){$input_fields{'cpassw'} .= " Please reenter and confirm password";
      $input_error = 1;}
  return $input_error;
}

sub html_form {
  my $self = shift;
  return <<EOF;
<form  method=post>
<table>
<TR><TD colspan=2>
<strong>Required Fields</strong>
</TD></TR><TR><TD>
User Name
</TD><TD>
$input_fields{'user'}
</TD></TR><TR><TD>
Password<br>
</TD><TD>
$input_fields{'password'}
</TD></TR><TR><TD>
Confirm Password
</TD><TD>
$input_fields{'cpassw'}
</TD></TR><TR><TD>
Email
</TD><TD>
$input_fields{'email'}
</TD></TR><TR><TD colspan=2>
<strong>Personal Information</strong>
</TD></TR><TR><TD>
First name
</TD><TD>
$input_fields{'first_name'}
</TD></TR><TR><TD>
MI
</TD><TD>
$input_fields{'middle_initial'}
</TD></TR><TR><TD>
Last name
</TD><TD>
$input_fields{'last_name'}
</TD></TR><TR><TD>
City
</TD><TD>
$input_fields{'city'}
</TD></TR><TR><TD>
State
</TD><TD>
$input_fields{'state'}
</TD></TR><TR><TD>
Country
</TD><TD>
$input_fields{'country'}
</TD></TR><TR><TD colspan=2>
<input type="hidden" name="action" value="register">
<CENTER>
<input type="submit" name="submit" value="Submit">&nbsp;&nbsp;<input type="reset" value="Reset" name="reset"></CENTER>
</TD></TR>
</TABLE>
</form>
EOF
}