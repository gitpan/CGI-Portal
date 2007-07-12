package CGI::Portal::Scripts::logoff;
# Copyright (c) 2005 Alexander David. All rights reserved.

use strict;
use CGI::Portal::Scripts::logon;
use CGI::Portal::Sessions;
use vars qw(@ISA $VERSION);
$VERSION = "0.08";

@ISA = qw(CGI::Portal::Sessions);

1;

sub launch {
  my $self = shift;
  $self->authenticate_user();
  if ($self->{'user'}){
    $self->logoff;
    bless $self, "CGI::Portal::Scripts::logon";
    $self->launch;
  }
}