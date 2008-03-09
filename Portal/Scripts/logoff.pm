package CGI::Portal::Scripts::logoff;
# Copyright (c) 2008 Alexander David P. All rights reserved.
#
# Remove session

use strict;
use CGI::Portal::Scripts::logon;
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

            # Remove session
    $self->logoff;

            # Redirect
    bless $self, "CGI::Portal::Scripts::logon";
    $self->launch;
  }
}