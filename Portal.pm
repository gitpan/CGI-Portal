package CGI::Portal;
# Copyright (c) 2005 Alexander David. All rights reserved.

use strict;
use CGI::Portal::RDB;
use CGI::Portal::Scripts::Header;
use CGI::Portal::Scripts::Footer;
use CGI;
use HTML::Template;
use vars qw($VERSION);
$VERSION = "0.04";

my $h;
my $f;
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

  $h = CGI::Portal::Scripts::Header->new({});
  $h->launch($e);
  $f = CGI::Portal::Scripts::Footer->new({});
  $f->launch($e);

  print $e->{'cookies'};
  print $cgi->header;
  print $h->{'out'};
  print $e->{'out'};
  print $f->{'out'};
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
                           'user_additional'     => ["email","first_name","middle_initial","last_name","city","state","country"],
                           # at least:              ["email"],

                           'session_table'       => "sessions",
                           'session_index_field' => "id",
                           'session_sid_field'   => "sid",
                           'session_user_field'  => "user",
                           'session_start_field' => "session_start",
                           'session_additional'  => "",


                           # Modules in the CGI::Portal::Scripts namespace, the first is the default action

                           'actions'             => ["logon", "logoff", "register", "profile", "changepw", "emailpw"],

                           'session_length'      => 7200,
                           'admin_email'         => "some_user\@some_host.com",

                           'template_dir'        => "templates/", # include trailing slash
                           'header_html'         => "header.html",
                           'footer_html'         => "footer.html",
                           'logon_success_html'  => "logon.html"});

=head1 DESCRIPTION

CGI::Portal is a framework for the design of extensible,
plug-configure-and-play multiuser web applications based on preferred object
oriented coding standards. It provides authentication, session management, internal 
redirects and a modular architecture to build complex applications.

It requires a database including a user and a sessions table, a collection of HTML::Template
style templates and a properly configured startup script. To start you may want to install
the provided L<Templates|http://cpan.org/pub/CPAN/authors/id/A/AL/ALPO/Templates/Templates.tar.gz>.

All requests access through the startup script, and are handled by the module in
the CGI::Portal::Scripts namespace that corresponds to the desired action. Above shown
actions are included in CGI::Portal.

For example, portal.cgi?action=foo calls CGI::Portal::Scripts::foo::launch()

=head1 FUNCTIONS

=head2 activate

CGI::Portal::activate($conf) takes a reference to the configuration hash, collects
input parameters, creates a database object, and passes those on to your module
for creating an object instance. It then runs your modules "launch" method and
concludes by doing the printing for you. This function is called once from your
startup script.

=head1 BUILDING APPLICATIONS

See CGI::Portal::Scripts on Building Applications

=head1 INSTALLATION

    perl Makefile.PL
    make
    make test
    make install

=head1 AUTHOR

Alexander David <cpanalpo@yahoo.com>

=cut