package CGI::Portal::Scripts::profile;
# Copyright (c) 2005 Alexander David. All rights reserved.

use strict;
use Digest::MD5 qw(md5_hex);
use CGI::Portal::Sessions;
use vars qw(@ISA $VERSION);
$VERSION = "0.02";

@ISA = qw(CGI::Portal::Sessions);

my %input_fields;
my $r;
my $expires;

1;

sub launch {
  my $self = shift;
  $self->authenticate_user();
  if ($self->{'user'}){
    $r = $self->{'rdb'}->exec("select $self->{'conf'}{'user_email_field'},$self->{'conf'}{'add_user_fields'} from $self->{'conf'}{'user_table'} where $self->{'conf'}{'user_user_field'}=" . $self->{'rdb'}->escape($self->{'user'}) . " limit 1")->fetch;
    $self->input_html();
    if ($self->{'in'}{'submit'}){
      unless ($self->input_error("email")){
        my $user = $self->{'rdb'}->escape($self->{'user'});
        my $email = $self->{'rdb'}->escape($self->{'in'}{'email'});
        my $first_name = $self->{'rdb'}->escape($self->{'in'}{'first_name'});
        my $middle_initial = $self->{'rdb'}->escape($self->{'in'}{'middle_initial'});
        my $last_name = $self->{'rdb'}->escape($self->{'in'}{'last_name'});
        my $city = $self->{'rdb'}->escape($self->{'in'}{'city'});
        my $state = $self->{'rdb'}->escape($self->{'in'}{'state'});
        my $country = $self->{'rdb'}->escape($self->{'in'}{'country'});
        $self->{'rdb'}->exec("update $self->{'conf'}{'user_table'} set $self->{'conf'}{'user_email_field'}=$email where $self->{'conf'}{'user_user_field'}=$user") if ($self->{'in'}{'email'} ne $r->[0]);
        $self->{'rdb'}->exec("update $self->{'conf'}{'user_table'} set first_name=$first_name where $self->{'conf'}{'user_user_field'}=$user") if ($self->{'in'}{'first_name'} ne $r->[1]);
        $self->{'rdb'}->exec("update $self->{'conf'}{'user_table'} set middle_initial=$middle_initial where $self->{'conf'}{'user_user_field'}=$user") if ($self->{'in'}{'middle_initial'} ne $r->[2]);
        $self->{'rdb'}->exec("update $self->{'conf'}{'user_table'} set last_name=$last_name where $self->{'conf'}{'user_user_field'}=$user") if ($self->{'in'}{'last_name'} ne $r->[3]);
        $self->{'rdb'}->exec("update $self->{'conf'}{'user_table'} set city=$city where $self->{'conf'}{'user_user_field'}=$user") if ($self->{'in'}{'city'} ne $r->[4]);
        $self->{'rdb'}->exec("update $self->{'conf'}{'user_table'} set state=$state where $self->{'conf'}{'user_user_field'}=$user") if ($self->{'in'}{'state'} ne $r->[5]);
        $self->{'rdb'}->exec("update $self->{'conf'}{'user_table'} set country=$country where $self->{'conf'}{'user_user_field'}=$user") if ($self->{'in'}{'country'} ne $r->[6]);
      }
    }
    $self->{'out'} = $self->html_form();
  }
}

sub input_html {
  my $self = shift;
  my $email = $self->{'in'}{'email'} || $r->[0];
  my $first_name = $self->{'in'}{'first_name'} || $r->[1];
  my $middle_initial = $self->{'in'}{'middle_initial'} || $r->[2];
  my $last_name = $self->{'in'}{'last_name'} || $r->[3];
  my $city = $self->{'in'}{'city'} || $r->[4];
  my $state = $self->{'in'}{'state'} || $r->[5];
  my $country = $self->{'in'}{'country'} || $r->[6];
  my @states = qw(Other AL AK AZ AR CA CO CT DC DE FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VA VT WA WV WI WY);
  $input_fields{'email'} .= "<input type=text name=email size=64  value=\"$email\">";
  $input_fields{'first_name'} .= "<input type=text name=first_name size=64  value=\"$first_name\">";
  $input_fields{'middle_initial'} .= "<input type=text name=middle_initial size=4  value=\"$middle_initial\">";
  $input_fields{'last_name'} .= "<input type=text name=last_name size=64  value=\"$last_name\">";
  $input_fields{'city'} .= "<input type=text name=city size=64  value=\"$city\">";
  $input_fields{'state'} .= "<select name=state>";
  foreach my $s (@states){
    if ($s ne $state){
      $input_fields{'state'} .=  "<option>$s";
    }else{
      $input_fields{'state'} .=  "<option selected>$s";
    }
  }
  $input_fields{'state'} .= "</select>";
  $input_fields{'country'} .= "<input type=text name=country size=64  value=\"$country\">";
}

sub input_error {
  my $self = shift;
  my $input_error = 0;
  my @requireds = @_;
  foreach my $required (@requireds){
    if (!$self->{'in'}{$required}){
      $input_fields{$required} .= " Field is required</FONT>";
      $input_error = 1;
    }
  }
  return $input_error;
}

sub html_form {
  my $self = shift;
  return <<EOF;
<form  method=post>
<table>
<TR><TD>
<strong>Required Fields</strong>
</TD><TD>
<a href="$ENV{'SCRIPT_NAME'}?action=changepw">Change Password</a>
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
<input type="hidden" name="action" value="profile">
<CENTER>
<input type="submit" name="submit" value="Submit">&nbsp;&nbsp;<input type="reset" value="Reset" name="reset">
</CENTER>
</TD></TR>
</TABLE>
</form>
EOF
}