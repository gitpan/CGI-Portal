package CGI::Portal::Scripts::profile;
# Copyright (c) 2005 Alexander David. All rights reserved.

use strict;
use Digest::MD5 qw(md5_hex);
use CGI::Portal::Sessions;
use vars qw(@ISA $VERSION);
$VERSION = "0.04";

@ISA = qw(CGI::Portal::Sessions);

my $template;
my $r;

1;

sub launch {
  my $self = shift;
  $self->authenticate_user();
  if ($self->{'user'}){
    $template = HTML::Template->new(filename => "$self->{'conf'}{'template_dir'}profile.html");
    $template->param(SCRIPT_NAME => $ENV{'SCRIPT_NAME'});
    my $fields = join(',', @{$self->{'conf'}{'user_additional'}});
    $r = $self->{'rdb'}->exec("select $fields from $self->{'conf'}{'user_table'} where $self->{'conf'}{'user_user_field'}=" . $self->{'rdb'}->escape($self->{'user'}) . " limit 1")->fetch;
    $self->input_html();
    if ($self->{'in'}{'submit'}){
      unless ($self->input_error("email")){
        my $user = $self->{'rdb'}->escape($self->{'user'});
        my $c = 0;
        foreach my $f (@{$self->{'conf'}{'user_additional'}}) {
          my $value = $self->{'rdb'}->escape($self->{'in'}{$f});
          $self->{'rdb'}->exec("update $self->{'conf'}{'user_table'} set $f=$value where $self->{'conf'}{'user_user_field'}=$user") if ($self->{'in'}{$f} ne $r->[$c]);
          $c++;
        }
        $template->param(HOME => "Profile is updated.");
      }
    }
    $self->{'out'} = $template->output;
  }
}

sub input_html {
  my $self = shift;
  my @states = qw(Other AL AK AZ AR CA CO CT DC DE FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VA VT WA WV WI WY);
  my $c = 0;
  foreach my $f (@{$self->{'conf'}{'user_additional'}}) {
    my $value = $self->{'in'}{$f} || $r->[$c];
    $template->param($f => $value);
    $c++;
  }
  my $state_input = $self->{'in'}{'state'} || $r->[5];
  my $state = "<select name=state>";
  foreach my $s (@states){
    if ($s ne $state_input){
      $state .=  "<option>$s";
    }else{
      $state .=  "<option selected>$s";
    }
  }
  $state .= "</select>";
  $template->param(state => $state);
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
  return $input_error;
}