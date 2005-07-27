package CGI::Portal;
# Copyright (c) 2005 Alexander David. All rights reserved.

use strict;
use CGI::Portal::RDB;
use CGI;
use vars qw($VERSION);
$VERSION = "0.02";

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
  open (HEADER, "$e->{'conf'}{'header_html'}");
  while (<HEADER>){print;}
  close(HEADER);
  if ($e->{'user'}){on_html($e);}else{off_html();}
  print $e->{'out'};
  open (FOOTER, "$e->{'conf'}{'footer_html'}");
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
                           # does not add fields to your user table ;-)

                           'session_table'       => "sessions",
                           'session_index_field' => "id",
                           'session_sid_field'   => "sid",
                           'session_user_field'  => "user",
                           'session_start_field' => "session_start",
                           'add_session_fields'  => "",
                           # does not add fields to your session table ;-)


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
    and extend CGI::Portal::Scripts. CGI::Portal does not create database tables
    for you, so you will have to do that yourself.

    All requests go through the startup script, CGI::Portal then calls a module in
    the CGI::Portal::Scripts namespace depending on the desired action. Above shown
    actions are included in CGI::Portal.

    For example, portal.cgi?action=foo calls CGI::Portal::Scripts::foo::launch()

=head1 Functions

=head2 activate

    CGI::Portal::activate($conf) takes a reference to the configuration hash, collects
    input parameters, creates a database object, and passes those on to your module
    for creating an object instance. It then runs your modules "launch" method and
    concludes by doing the printing for you. This function is called once from your
    startup script.

=head1 Building Applications

    See CGI::Portal::Scripts on Building Applications

=head1 INSTALLATION

    perl Makefile.PL
    make
    make test
    make install

=head1 AUTHOR

    Alexander David <cpanalpo@yahoo.com>

=cut