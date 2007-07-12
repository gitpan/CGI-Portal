package CGI::Portal::Scripts::Footer;
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
  my $template = HTML::Template->new(filename => "$e->{'conf'}{'template_dir'}$e->{'conf'}{'footer_html'}");
  $self->{'out'} = $template->output;
}