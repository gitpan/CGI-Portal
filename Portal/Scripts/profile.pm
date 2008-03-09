package CGI::Portal::Scripts::profile;
# Copyright (c) 2008 Alexander David P. All rights reserved.
#
# Update user info

use strict;
use Digest::MD5 qw(md5_hex);
use CGI::Portal::Sessions;

use vars qw(@ISA $VERSION);
$VERSION = "0.10";

@ISA = qw(CGI::Portal::Sessions);

my $template;
my $r;

1;

sub launch {
  my $self = shift;

            # Authenticate
  $self->authenticate_user();
  if ($self->{'user'}){

            # Read template
    $template = HTML::Template->new(filename => "$self->{'conf'}{'template_dir'}profile.html");
    $template->param(SCRIPT_NAME => $ENV{'SCRIPT_NAME'});

            # Join user fields for SQL
    my $fields = join(',', @{$self->{'conf'}{'user_additional'}});

            # Select users info
    $r = $self->{'rdb'}->exec("select $fields from $self->{'conf'}{'user_table'} where $self->{'conf'}{'user_user_field'}=" . $self->{'rdb'}->escape($self->{'user'}) . " limit 1")->fetch;

            # Assign template vars
    $self->input_html();

            # Form action
    if ($self->{'in'}{'submit'}){

            # Validate
      unless ($self->input_error("email")){

            # Escape user
        my $user = $self->{'rdb'}->escape($self->{'user'});

            # Loop thru user fields and update
        my $c = 0;
        foreach my $f (@{$self->{'conf'}{'user_additional'}}) {
          my $value = $self->{'rdb'}->escape($self->{'in'}{$f});
          $self->{'rdb'}->exec("update $self->{'conf'}{'user_table'} set $f=$value where $self->{'conf'}{'user_user_field'}=$user") if ($self->{'in'}{$f} ne $r->[$c]);
          $c++;
        }

        $template->param(HOME => "Profile is updated.");
      }
    }

            # Assign template output to out
    $self->{'out'} = $template->output;
  }
}

            # Assign templ vars
sub input_html {
  my $self = shift;
  my @states = qw(Other AL AK AZ AR CA CO CT DC DE FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VA VT WA WV WI WY);

            # Template vars for user fields
  my $c = 0;
  foreach my $f (@{$self->{'conf'}{'user_additional'}}) {
    my $value = $self->{'in'}{$f} || $r->[$c];
    $template->param($f => $value);
    $c++;
  }

            # Default state
  my $state_input = $self->{'in'}{'state'} || $r->[5];

            # HTML select for state
  my $state = "<select name=state>";
  foreach my $s (@states){
    if ($s ne $state_input){
      $state .=  "<option>$s";
    }else{
      $state .=  "<option selected>$s";
    }
  }
  $state .= "</select>";

            # Assign to template var state
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

  return $input_error;
}