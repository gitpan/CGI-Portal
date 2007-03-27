package CGI::Portal::Scripts;
# Copyright (c) 2005 Alexander David. All rights reserved.

use strict;
use CGI::Portal::Sessions;
use vars qw(@ISA $VERSION);
$VERSION = "0.04";

@ISA = qw(CGI::Portal::Sessions);

1;

=head1 NAME

CGI::Portal::Scripts - Building Applications

=head1 SYNOPSIS

    package CGI::Portal::Scripts::some_name;

    use CGI::Portal::Scripts;
    use vars qw(@ISA);

    @ISA = qw(CGI::Portal::Scripts);

    1;

    sub launch {
      my $self = shift;
      .... 
    }

=head2 Internal Redirect

    package CGI::Portal::Scripts::some_name;

    use CGI::Portal::Scripts;
    use CGI::Portal::Scripts::other_name;
    use vars qw(@ISA);

    @ISA = qw(CGI::Portal::Scripts);

    1;

    sub launch {
      my $self = shift;
      .... 

      bless $self, "CGI::Portal::Scripts::other_name";
      $self->launch;
    }

=head1 DESCRIPTION

Applications based on CGI::Portal are build by creating modules that reside in the
CGI::Portal::Scripts namespace and extend CGI::Portal::Scripts. These modules
must provide a subroutine launch() that CGI::Portal calls as an object method to
run your modules code.

A subroutine new() is not necessary or helpful as you are extending CGI::Portal::Scripts.

In your modules, do not print() or exit(). Instead of "print"ing append to $self->{'out'}
or $self->{'cookies'} and instead of "exit"ing, "return" from launch().

Extending CGI::Portal::Scripts, gives you access to an object with the following attributes.

=head1 ATTRIBUTES

=head2 conf

$self->{'conf'} references a hash containing all values as set in the startup script.

=head2 in

$self->{'in'} references a hash containing all input parameters, stripped off any HTML tags.

=head2 user

$self->{'user'} is set by $self->authenticate_user() if logon succeeds.

=head2 rdb

$self->{'rdb'} is a CGI::Portal::RDB database object holding a database handle.

=head2 out

$self->{'out'} supposed to collect all output.

=head2 cookies

$self->{'cookies'} collects cookie headers you might want to set. It is also used for
Sessions, so you might want to append to it.

=head1 FUNCTIONS

=head2 authenticate_user

$self->authenticate_user() takes no arguments and does not return anything. It sets
$self->{'user'} and starts a session if user logon succeeds. If user logon fails
it writes the HTML for a logon form to $self->{'out'}. It also maintains the sessions
during subsequent calls.

    $self->authenticate_user();
    return unless $self->{'user'};
    ....

=head2 logoff

$self->logoff() takes no arguments and does not return anything. It removes the current
users session id from the database and unsets the session cookie.

=head2 RDB->exec

$self->{'rdb'}->exec($sql) is an object method for the database object. It takes a SQL
statement as argument and returns a DBI statement handle.

The database handle can be directly retrieved from $self->{'rdb'}{'dbh'}.

=head2 RDB->escape

$self->{'rdb'}->escape(@values) takes an array of SQL values. It uses DBI's quote() on those
values and returns them as a string seperated by commas.

=head1 AUTHOR

Alexander David <cpanalpo@yahoo.com>

=cut