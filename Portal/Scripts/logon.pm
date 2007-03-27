package CGI::Portal::Scripts::logon;
# Copyright (c) 2005 Alexander David. All rights reserved.

use strict;
use CGI::Portal::Sessions;
use vars qw(@ISA $VERSION);
$VERSION = "0.04";

@ISA = qw(CGI::Portal::Sessions);

1;

sub launch {
  my $self = shift;
  $self->authenticate_user();
  if ($self->{'user'}){
    my $template = HTML::Template->new(filename => "$self->{'conf'}{'template_dir'}$self->{'conf'}{'logon_success_html'}");
    $self->{'out'} = $template->output;
  }
}