package CGI::Portal::Scripts::changepw;
# Copyright (c) 2005 Alexander David. All rights reserved.

use strict;
use Digest::MD5 qw(md5_hex);
use CGI::Portal::Sessions;
use vars qw(@ISA $VERSION);
$VERSION = "0.04";

@ISA = qw(CGI::Portal::Sessions);

my $template;
my $passw;

1;

sub launch {
  my $self = shift;
  $self->authenticate_user();
  if ($self->{'user'}){
    $template = HTML::Template->new(filename => "$self->{'conf'}{'template_dir'}changepw.html");
    $template->param(SCRIPT_NAME => $ENV{'SCRIPT_NAME'});
    if ($self->{'in'}{'submit'}){
      my $users = $self->{'rdb'}->exec("select $self->{'conf'}{'user_passw_field'} from $self->{'conf'}{'user_table'} where $self->{'conf'}{'user_user_field'}=" . $self->{'rdb'}->escape($self->{'user'}) . " limit 1")->fetch;
      $passw = $users->[0];
      unless ($self->input_error("pass_new","cpass_new","passw")){
        my $enc_passw = md5_hex($self->{'in'}{'pass_new'});
        $self->{'rdb'}->exec("update $self->{'conf'}{'user_table'} set $self->{'conf'}{'user_passw_field'}=\'$enc_passw\' where $self->{'conf'}{'user_user_field'}=" . $self->{'rdb'}->escape($self->{'user'}));
        $template->param(MSG => "Password updated!");
      }
    }
    $self->{'out'} = $template->output;
  }
}

sub input_error {
  my ($self, @requireds)  = @_;
  my $input_error = 0;
  foreach my $required (@requireds) {
    if (!$self->{'in'}{$required}){
      $template->param("${required}_msg" => "Field is required");
      $input_error = 1;
    }
  }
  if ($self->{'in'}{'passw'} &&  md5_hex($self->{'in'}{'passw'}) ne $passw) {
    $template->param(passw_msg => "Incorrect Password");
    $input_error = 1;
  }
  if ($self->{'in'}{'pass_new'} && $self->{'in'}{'pass_new'} !~ /..../i) {
    $template->param(pass_new_msg => "Passwords must consist of at least 4 characters");
    $input_error = 1;
  }
  if ($self->{'in'}{'cpass_new'} && $self->{'in'}{'pass_new'} ne $self->{'in'}{'cpass_new'}) {
    $template->param(cpass_new_msg => "Please reenter and confirm password");
    $input_error = 1;
  }
  return $input_error;
}