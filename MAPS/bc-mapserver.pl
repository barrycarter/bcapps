#!/bin/perl

# TODO: I might be able to use this via xinetd or websocket proxy, see
# if I want do to that though

# TODO: https (or proxy)

# The main map server

require "/usr/local/lib/bclib.pl";
use IO::Socket::UNIX;

# ignore children completion
$SIG{CHLD} = 'IGNORE';

# for testing, seek to the first available port (when this prog dies,
# the socket can keep living for a bit, sigh)

# TODO: undo this

warn "TESTING, socket varies";

my $server;

my($port) = 22779-1;

do {
  $port++;
  $server = IO::Socket::INET->new(LocalAddr => "127.0.0.1", 
   LocalPort => $port, Proto => "tcp", Listen => 20);

} until $server;
				  
debug("LISTENING ON PORT $port");

while (my $conn = $server->accept()) {

  # fork (parent ignores, child handles)

  debug("GOT CONNECTION, forking off");

  if (fork()) {next;}

  # TODO: set ALRM to timeout to avoid hangs

  my(@data);
  my($req);

  while ($in = <$conn>) {
    debug("GOT: $in");
    push(@data, $in);
    
    # TODO: handle POST/etc requests nicely
    
    # the GET line (allows for non-HTTP/1.1 requests if they have no spaces
    # note the / is not considered part of the request

    if ($in=~m%^GET\s*/(\S+)%) {$request = $1; next;}

    # the blank line means end of headers
    if ($in=~/^\s*$/) {last;}
  }

  # process request

  debug("PROCESSING: $request");
  my($ret) = JSON::to_json(mapData(str2hashref($request)));

  # TODO: this should print as header but isnt for some reason
#  print $conn "Content-type: text/plain\n\n";
  
  print $conn $ret;

  # as the child, I must exit
  exit();

}

=item mapData(%hash)

Given hash below, return the associated data in the data field of a hash:

name: name of the map, either a SHP file or a TIF

z, x, y: the z/x/y tile desired, on a equirectanagular projection

layer: the layer to burn

=cut

sub mapData {

  my($hr) = @_;
  my($out, $err, $res);

  debug("mapData(", %{$hr},")");

  # determine lat/lng extents

  # tile width/height in degrees

  my($width) = 360/2**$hr->{z};

  my($wlng) = $hr->{x}*$width - 180;
  my($elng) = $wlng + $width;

  my($nlat) = 90-$hr->{y}*$width/2;
  my($slat) = $nlat - $width/2;

  # with of a pixel, for gdal_rasterize or warp
  my($tr) = $width/256;

  # if the name ends in shp, we use gdal_rasterize

  if ($hr->{name}=~/\.shp$/i) {
    # TODO: using Int16 here is unnecessary in some cases
    # TODO: of course, we may need Float or something later, so bad both ways
    # TODO: nonfixed tmpfile

    my($tmp) = my_tmpfile2();

    my($cmd) = "gdal_rasterize -ot Int16 -tr $tr $tr -te $wlng $slat $elng $nlat -of Ehdr -a $hr->{layer} $hr->{name} $tmp";

    debug("COMMAND: $cmd");

    ($out, $err, $res) = cache_command2($cmd, "age=3600");
  }

  $hr->{data} = read_file($tmp);

  return $hr;

}

die "TESTING";

# TODO: generalize these paths
require "$bclib{githome}/MAPS/bc-mapserver-lib.pl";
require "$bclib{githome}/MAPS/bc-mapserver-commands.pl";

my($ans) = process_command(str2hashref("cmd=time&foo=bar&i=hero"));

# user won't be able to call this, but I can for testing

for ($i=35; $i<36; $i += 1/$meta{landuse}{dataPointsPerDegree}) {
  for ($j=-107; $j<-106; $j += 1/$meta{landuse}{dataPointsPerDegree}) {
    $ans = landuse(str2hashref("lat=$i&lon=$j"));
    print "$i $j $ans->{value}\n";
  }
}

$ans = landuse(str2hashref("lat=35.05&lon=-106.5"));

debug(var_dump("ans", $ans));




