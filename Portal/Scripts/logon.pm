package CGI::Portal::Scripts::logon;
# Copyright (c) 2005 Alexander David. All rights reserved.

use strict;
use CGI::Portal::Sessions;
use vars qw(@ISA $VERSION);
$VERSION = "0.02";

@ISA = qw(CGI::Portal::Sessions);

1;

sub launch {
  my $self = shift;
  $self->authenticate_user();
  if ($self->{'user'}){
    open (LOGON, "$self->{'conf'}{'logon_success_html'}");
    while (<LOGON>){$self->{'out'} .= $_;}
    close(LOGON);
  }
}