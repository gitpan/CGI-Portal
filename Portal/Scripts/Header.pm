package CGI::Portal::Scripts::Header;
# Copyright (c) 2005 Alexander David. All rights reserved.

use strict;
use vars qw($VERSION);
$VERSION = "0.08";

1;

sub new {
  my ($class, $i) = @_;
  bless $i, $class;
  return $i;
}

sub launch {
  my ($self, $e) = @_;
  my $template = HTML::Template->new(filename => "$e->{'conf'}{'template_dir'}$e->{'conf'}{'header_html'}");
  $template->param(SCRIPT_NAME => $ENV{'SCRIPT_NAME'});
  $self->{'out'} = $template->output;
}