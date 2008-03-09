package CGI::Portal::Scripts::Header;
# Copyright (c) 2008 Alexander David P. All rights reserved.
#
# Code for header

use strict;

use vars qw($VERSION);
$VERSION = "0.10";

1;

sub new {
  my ($class, $i) = @_;
  bless $i, $class;
  return $i;
}

sub launch {
  my ($self, $e) = @_;

            # Read the template
  my $template = HTML::Template->new(filename => "$e->{'conf'}{'template_dir'}$e->{'conf'}{'header_html'}");
  $template->param(SCRIPT_NAME => $ENV{'SCRIPT_NAME'});

            # Assign template output to  object out
  $self->{'out'} = $template->output;
}