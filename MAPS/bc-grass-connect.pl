#!/bin/perl

# this script (which will eventually be a daemon) connects to the
# GRASS shell to create PNG files on demand from vector maps

use IO::Socket;
require "/usr/local/lib/bclib.pl";

# listen on port 22779 properly

my $socket = IO::Socket::INET->new(Timeout => 2, LocalPort => 22779, Listen => 50);

$socket->{timeout} = 2;

# socket(S,PF_INET,SOCK_STREAM,(getprotobyname('tcp')));
# bind(S,sockaddr_in(22779,INADDR_ANY))||die("Can't bind, $!");
# listen(S,SOMAXCONN)||die("Can't listen, $!");

while (true) {

  debug("Entering infinite loop");

  accept(C,$socket);

  # wait for the "double new line" to end it
  while (<C>) {

    debug("GOT: *$_*");

    if (/^\s*$/) {last;}
  }

debug("SEnding reply");

print C "Content-type: text/html\r\n\r\nYou said: `date`\r\n";

close(C);

}


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

=item todo

The following MAY let me connect to grass without the grass shell, but
might be harder, so abandoned for now.

# trying to connect to the grass shell without actually invoking it
# via ENV vars or full paths

my($bin) = "/usr/local/grass-7.4.1/bin/";

GISBASE=/usr/local/grass-7.4.1
GISRC=/tmp/grass7-user-26669/gisrc
GIS_LOCK=26669
GRASS_ADDON_BASE=/mnt/villa/user/.grass7/addons
GRASS_GNUPLOT=gnuplot -persist
GRASS_HTML_BROWSER=xdg-open
GRASS_PAGER=more
GRASS_PROJSHARE=/usr/share/proj
GRASS_PYTHON=python
GRASS_VERSION=7.4.1
LD_LIBRARY_PATH=/usr/local/grass-7.4.1/lib:/lib64:/usr/local/lib:/usr/lib:/lib
PYTHONPATH=/usr/local/grass-7.4.1/etc/python

=cut
