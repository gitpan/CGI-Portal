package CGI::Portal::Scripts::register;
# Copyright (c) 2008 Alexander David P. All rights reserved.
#
# Insert user info

use strict;
use Digest::MD5 qw(md5_hex);
use CGI::Portal::Scripts::logon;
use CGI::Portal::Sessions;

use vars qw(@ISA $VERSION);
$VERSION = "0.10";

@ISA = qw(CGI::Portal::Sessions);

my $template;

1;

sub launch {
  my $self = shift;

            # Read template
  $template = HTML::Template->new(filename => "$self->{'conf'}{'template_dir'}register.html");
  $template->param(SCRIPT_NAME => $ENV{'SCRIPT_NAME'});

            # Assign template vars
  $self->input_html();

            # Form action
  if ($self->{'in'}{'submit'}){

            # Validate
    unless ($self->input_error("user","password","cpassw","email")){

            # Get the current index
      my $cc = $self->{'rdb'}->exec("select $self->{'conf'}{'user_index_field'} from $self->{'conf'}{'user_table'} order by $self->{'conf'}{'user_index_field'} desc limit 1")->fetch;
      my $c = $cc->[0]+1;

            # Hash the passw
      my $enc_passw = md5_hex($self->{'in'}{'password'});

            # Collect values for SQL
      my @additional_values;
      foreach my $f (@{$self->{'conf'}{'user_additional'}}) {
        push(@additional_values, $self->{'in'}{$f});
      }

            # Escape values
      my $values = $self->{'rdb'}->escape($c,$self->{'in'}{'user'},$enc_passw,@additional_values);

            # Join fields for SQL
      my $fields = join(',', @{$self->{'conf'}{'user_additional'}});

            # Insert
      $self->{'rdb'}->exec("insert into $self->{'conf'}{'user_table'} ($self->{'conf'}{'user_index_field'},$self->{'conf'}{'user_user_field'},$self->{'conf'}{'user_passw_field'},$fields) values ($values)");

            # Assign user to object
      $self->{'user'} = $self->{'in'}{'user'};

            # Redirect
      bless $self, "CGI::Portal::Scripts::logon";
      $self->launch;
      return;
    }
  }

            # Assign template output to object out
  $self->{'out'} = $template->output;
}

            # Assign template vars
sub input_html {
  my $self = shift;
  my @states = qw(Other AL AK AZ AR CA CO CT DC DE FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VA VT WA WV WI WY);

            # Assign template var user
  $template->param(user => $self->{'in'}{'user'});

            # Assign template vars for user fields
  foreach my $f (@{$self->{'conf'}{'user_additional'}}) {
    $template->param($f => $self->{'in'}{$f});
  }

            # HTML select for state
  my $state = "<select name=state>";
  foreach my $s (@states){
    if ($s ne $self->{'in'}{'state'}){
      $state .=  "<option>$s";
    }else{
      $state .=  "<option selected>$s";
    }
  }
  $state .= "</select>";

            # Assign template var state
  $template->param(state => $state);
}

            # Validate
sub input_error {
  my ($self, @requireds)  = @_;
  my $input_error = 0;

            # Loop thru requireds
  foreach my $required (@requireds) {
    if (!$self->{'in'}{$required}){
      $template->param("${required}_msg" => "Field is required");
      $input_error = 1;
    }
  }

            # See if user name is available
  my $r = $self->{'rdb'}->exec("select $self->{'conf'}{'user_index_field'} from $self->{'conf'}{'user_table'} where $self->{'conf'}{'user_user_field'} like " . $self->{'rdb'}->escape($self->{'in'}{'user'}) . " limit 1")->fetch;
  if ($r->[0]) {
    $template->param(user_msg => "User name $self->{'in'}{'user'} is not available");
    $input_error = 1;
  }

            # User name requirements
  if ($self->{'in'}{'user'} && $self->{'in'}{'user'} =~ /[^\w ]/i) {
    $template->param(user_msg => "User names must consist of letters or numbers");
    $input_error = 1;
  }
  if ($self->{'in'}{'user'} && $self->{'in'}{'user'} =~ / /i) {
    $template->param(user_msg => "User names cannot contain spaces");
    $input_error = 1;
  }
  if ($self->{'in'}{'user'} && $self->{'in'}{'user'} =~ /................/i) {
    $template->param(user_msg => "User names must consist of less than 16 characters");
    $input_error = 1;
  }

            # Password requirements
  if ($self->{'in'}{'password'} && $self->{'in'}{'password'} !~ /..../i) {
    $template->param(password_msg => "Passwords must consist of at least 4 characters");
    $input_error = 1;
  }
  if ($self->{'in'}{'cpassw'} && $self->{'in'}{'password'} ne $self->{'in'}{'cpassw'}) {
    $template->param(cpassw_msg => "Please reenter and confirm password");
    $input_error = 1;
  }

  return $input_error;
}

sub html_form {
  my $self = shift;
  return <<EOF;
EOF
}