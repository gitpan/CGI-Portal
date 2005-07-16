package CGI::Portal;
# Copyright (c) 2005 Alexander David. All rights reserved.

use strict;
use CGI::Portal::RDB;
use CGI;
use vars qw($VERSION);
$VERSION = "0.01";

my $e;

1;

sub activate {
  my $conf = shift;
  my $cgi = new CGI();
  my @v = $cgi->param;
  my %in;
  foreach my $f (@v){
    my $v = $cgi->param($f);
    $v =~ s/<.*\r*\n*.*>//g;
    $in{$f} = $v;
  }

  my $rdb = CGI::Portal::RDB->new("DBI:$conf->{'database_type'}:database=$conf->{'database_name'};host=$conf->{'database_host'};", $conf->{'database_user'}, $conf->{'database_passw'});

  my $i = {'in',      \%in,
           'rdb',     $rdb,
           'conf',    $conf};

  my $c = "CGI::Portal::Scripts::$conf->{'actions'}[0]";
  foreach my $a (@{$conf->{'actions'}}) {
    if ($in{'action'} eq $a){
      $c = "CGI::Portal::Scripts::$a";
    }
  }
  eval "use $c;";
  $e = $c->new($i);
  $e->launch;

  print $e->{'cookies'};
  print $cgi->header;
  open (HEADER, "$conf->{'header_html'}");
  while (<HEADER>){print;}
  close(HEADER);
  if ($e->{'user'}){on_html($e);}else{off_html();}
  print $e->{'out'};
  open (FOOTER, "$conf->{'footer_html'}");
  while (<FOOTER>){print;}
  close(FOOTER);
}

sub on_html {
  my $e = shift;
  print <<EOF;
EOF
}

sub off_html {
  print <<EOF;
EOF
}

=head1 NAME

    CGI::Portal - Extensible Framework for Multiuser Applications

=head1 SYNOPSIS

    use CGI::Portal;

    CGI::Portal::activate({'database_type'       => "mysql",

                           'database_name'       => "some_name",
                           'database_host'       => "localhost",
                           'database_user'       => "some_user",
                           'database_passw'      => "some_password",

                           'user_table'          => "users",
                           'user_index_field'    => "id",
                           'user_user_field'     => "user",
                           'user_passw_field'    => "passw",
                           'user_email_field'    => "email",
                           'add_user_fields'     => "first_name,middle_initial,last_name,city,state,country",

                           'session_table'       => "sessions",
                           'session_index_field' => "id",
                           'session_sid_field'   => "sid",
                           'session_user_field'  => "user",
                           'session_start_field' => "session_start",
                           'add_session_fields'  => "",

                           # Modules in the CGI::Portal::Scripts namespace, the first is the default action
                           'actions'             => ["logon", "logoff", "register", "profile", "changepw", "emailpw"],

                           'session_length'      => 7200,
                           'admin_email'         => "some_user\@some_host.com",

                           'header_html'         => "header.html",
                           'footer_html'         => "footer.html",
                           'logon_success_html'  => "logon.html"});

=head1 DESCRIPTION

    CGI::Portal is intended as a framework for the design of extensible,
    plug-configure-and-play multiuser web applications based on preferred object
    oriented coding standards. It includes authentication and session management.

    Applications are build by first configuring a simple startup script as above
    and then by creating modules that reside in the CGI::Portal::Scripts namespace
    and extend CGI::Portal::Sessions. These modules must provide a subroutine "launch"
    that the application calls once it receives an "action" parameter equal to the
    modules names.

    For example, portal.cgi?action=foo calls CGI::Portal::Scripts::foo::launch().

    In your modules, do not "print" or "exit". Instead append to $self->{'out'} and
    return from launch().

=head1 Functions

=head2 activate
    CGI::Portal::activate($conf) collects input parameters, creates a database object,
    and passes those along with the configuration from $conf on to your module for
    creating an object instance. It then runs your modules "launch" method and
    concludes by doing the printing for you. This function is called once from your
    startup script.

=head2 Sessions->new
    CGI::Portal::Sessions->new($ref) is automatically called and receives the correct
    parameter if your modules extend CGI::Portal::Sessions.

=head2 Sessions->authenticate_user
    CGI::Portal::Sessions->authenticate_user() is an object method for use in your
    modules and sets the objects "user" property and starts a session if user logon
    succeeds. If user logon fails it writes the HTML for a logon form to $self->{'out'}.

=head2 RDB->exec
    CGI::Portal::RDB->exec($sql) is an object method for the database object accessible
    thru $self->{'rdb'}. It takes a SQL statement as argument and returns a DBI
    statement handle. Alternatively you can retrieve the database handle from
    $self->{'rdb'}{'dbh'}.

=head2 RDB->escape
    CGI::Portal::RDB->escape(@values) is also accessible thru $self->{'rdb'} and takes
    an array of SQL values. It uses DBI's quote() on those values and returns them as a
    string seperated by commas.

=head1 Properties

=head2 conf
    $self->{'conf'} is a hash reference to all values as set in the startup script.

=head2 in
    $self->{'in'} is a hash reference to all input parameters, stripped off HTML tags.

=head2 user
    $self->{'user'} is set by $self->authenticate_user() if logon succeeds.

=head2 out
    $self->{'out'} supposed to collect all output. Append to it insted of "print"ing.

=head2 cookies
    $self->{'cookies'} collects cookie headers you might want to set. Also used for
    Sessions, so you might want to append to it.

=head1 INSTALLATION

    perl Makefile.PL
    make
    make test
    make install

=head1 AUTHOR

    Alexander David <cpanalpo@yahoo.com>

=cut