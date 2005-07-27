package CGI::Portal::RDB;
# Copyright (c) 2005 Alexander David. All rights reserved.

use strict;
use DBI;
use vars qw($VERSION);
$VERSION = "0.02";

1;

sub new {
  my ($class, $dsn, $user, $passw) = @_;
  my $i = {};
  $i->{'dbh'} = DBI->connect($dsn, $user, $passw);
  bless $i, $class;
  return $i;
}

sub escape {
  my ($self, @vals) = @_;
  my @esc_vals;
  foreach my $a (@vals) {
    push(@esc_vals, $self->{'dbh'}->quote($a));
  }
  return join(',', @esc_vals);
}

sub exec {
  my ($self, $sql) = @_;
  unless ($self->{'dbh'}){return;}
  my $sth = $self->{'dbh'}->prepare($sql);
  $sth->execute();
  return $sth;
}