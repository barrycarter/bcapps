#!/bin/perl

# this script (which will eventually be a daemon) connects to the
# GRASS shell to create PNG files on demand from vector maps

use Socket;
require "/usr/local/lib/bclib.pl";

# make sure we are inside a GRASS shell

unless ($ENV{GRASS_VERSION}) {die "Must run in GRASS shell";}

# listen on port 22779 properly

socket(S,PF_INET,SOCK_STREAM,(getprotobyname('tcp')));
bind(S,sockaddr_in(22779,INADDR_ANY))||die("Can't bind, $!");
listen(S,SOMAXCONN)||die("Can't listen, $!");

while (true) {

  my($req);

  accept(C,S);

  # wait for the "double new line" to end it
  # TODO: timeout!!!!

  while (<C>) {

    if (/^GET (\S+)$/) {$req = $1;}

    if (/^\s*$/) {last;}
  }

#  print C "HTTP/1.1 200 OK\nContent-type: text/html\n\n";
 
  print C "HTTP/1.1 200 OK\nContent-type: image/png\n\n";

  print C read_file("$bclib{githome}/temp.png");
  close(C);

}

=item flyfile($text)

TODO: seriously improve this

Returns the contents of a PNG file with $text written in it

=cut

sub flyfile {

  my($text) = @_;

  open(A, "|fly -q");

  print A


debug("ALL DONE");

# for $i (keys %ENV) {debug("$i -> $ENV{$i}");}


# let's run this program from WITHIN grass

# intentionally omitting /home/user/.grass7 from path

$ENV{PATH} = "/usr/local/grass-7.4.1/bin:/usr/local/grass-7.4.1/scripts:$ENV{PATH}";

my($out, $err, $res);

($out, $err, $res) = cache_command2("v.colors map=ne_10m_time_zones color=roygbiv use=attr column=zone");

debug("OUT: $out, ERR: $err, RES: $res");

($out, $err, $res) = cache_command2("g.region n=50 s=30 w=-120 e=-70 rows=256 cols=256");

debug("OUT: $out, ERR: $err, RES: $res");

($out, $err, $res) = cache_command2("v.to.rast --overwrite input=ne_10m_time_zones output=temp use=cat");

debug("OUT: $out, ERR: $err, RES: $res");

($out, $err, $res) = cache_command2("r.out.gdal --overwrite input=temp output=/tmp/GDAL-1234.png format=PNG");

debug("BETA");

