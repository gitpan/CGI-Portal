package CGI::Portal::Scripts::changepw;
# Copyright (c) 2008 Alexander David P. All rights reserved.
#
# Update users passw

use strict;
use Digest::MD5 qw(md5_hex);
use CGI::Portal::Sessions;

use vars qw(@ISA $VERSION);
$VERSION = "0.10";

@ISA = qw(CGI::Portal::Sessions);

my $template;
my $passw;

1;

sub launch {
  my $self = shift;

            # Authenticate
  $self->authenticate_user();
  if ($self->{'user'}){

            # Read the template
    $template = HTML::Template->new(filename => "$self->{'conf'}{'template_dir'}changepw.html");
    $template->param(SCRIPT_NAME => $ENV{'SCRIPT_NAME'});

            # Form action
    if ($self->{'in'}{'submit'}){

            # Get users password hash
      my $users = $self->{'rdb'}->exec("select $self->{'conf'}{'user_passw_field'} from $self->{'conf'}{'user_table'} where $self->{'conf'}{'user_user_field'}=" . $self->{'rdb'}->escape($self->{'user'}) . " limit 1")->fetch;
      $passw = $users->[0];

            # Validate
      unless ($self->input_error("pass_new","cpass_new","passw")){

            # Hash new passw
        my $enc_passw = md5_hex($self->{'in'}{'pass_new'});

            # Update
        $self->{'rdb'}->exec("update $self->{'conf'}{'user_table'} set $self->{'conf'}{'user_passw_field'}=\'$enc_passw\' where $self->{'conf'}{'user_user_field'}=" . $self->{'rdb'}->escape($self->{'user'}));
        $template->param(MSG => "Password updated!");
      }
    }
            # Assign template output to object out
    $self->{'out'} = $template->output;
  }
}

            # Validate
sub input_error {
  my ($self, @requireds)  = @_;
  my $input_error = 0;

            # Require this
  foreach my $required (@requireds) {
    if (!$self->{'in'}{$required}){
      $template->param("${required}_msg" => "Field is required");
      $input_error = 1;
    }
  }

            # Compare password hashes
  if ($self->{'in'}{'passw'} &&  md5_hex($self->{'in'}{'passw'}) ne $passw) {
    $template->param(passw_msg => "Incorrect Password");
    $input_error = 1;
  }

            # Passwords must have 4 chars
  if ($self->{'in'}{'pass_new'} && $self->{'in'}{'pass_new'} !~ /..../i) {
    $template->param(pass_new_msg => "Passwords must consist of at least 4 characters");
    $input_error = 1;
  }

            # Compare confirm password
  if ($self->{'in'}{'cpass_new'} && $self->{'in'}{'pass_new'} ne $self->{'in'}{'cpass_new'}) {
    $template->param(cpass_new_msg => "Please reenter and confirm password");
    $input_error = 1;
  }
  return $input_error;
}