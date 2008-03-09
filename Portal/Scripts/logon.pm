package CGI::Portal::Scripts::logon;
# Copyright (c) 2008 Alexander David P. All rights reserved.
#
# Authenticate

use strict;
use CGI::Portal::Sessions;

use vars qw(@ISA $VERSION);
$VERSION = "0.10";

@ISA = qw(CGI::Portal::Sessions);

1;

sub launch {
  my $self = shift;

            # Authenticate
  $self->authenticate_user();
  if ($self->{'user'}){

            # Read the template
    my $template = HTML::Template->new(filename => "$self->{'conf'}{'template_dir'}$self->{'conf'}{'logon_success_html'}");

            # Assign template output to object
    $self->{'out'} = $template->output;
  }
}