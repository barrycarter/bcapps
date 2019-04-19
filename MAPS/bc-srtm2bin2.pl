#!/bin/perl

# converts an AAIGRID to a binary file covering the Earth

# This version uses binary data files I created earlier, in the hopes
# that will be faster

# Required options <h>(yes, that's an oxymoron)</h>
#
# --dataPerDegree: number of data points per degree
# --bytesPerData: the number of bytes per data point
# --outputFile: the file where the bytes are written
# --dataAdd: the number added to each data point
# --inputFile: the input file (this could be a regular argument?)

use Number::Format 'format_number';
require "/usr/local/lib/bclib.pl";

# ensure all options are set (except maybe outputfile)

for $i ("dataPerDegree", "bytesPerData", "dataAdd") {
  unless (length($globopts{$i}) > 0) {
    die("Required options: --dataPerDegree --bytesPerData --dataAdd (can set last to zero if desire");
  }
}

unless ($globopts{outputFile}) {
  warn "No output file, just crunching some numbers";
}

# compute some values

my($width) = 360*$globopts{dataPerDegree};
my($height) = 180*$globopts{dataPerDegree}+1;

# reserve 1M bytes for header
my($reserve) = 10**6;

my($bytes) = $globopts{bytesPerData} * $width * $height + $reserve + 1;

print "Outfile: ", format_number($width), " by ", format_number($height)," by $globopts{bytesPerData} bytes per data point + ", format_number($reserve)," reserve =\n";

print format_number($bytes)," bytes total\n";

# check that outfile is big enough (if given)

if ($globopts{outputFile} && -s $globopts{outputFile} < $bytes) {
  die ("Output file $globopts{outputFile} is not big enough to handle data");
}

unless ($globopts{inputFile}) {die "No input file";}

debug("I: $globopts{inputFile}");

if ($globopts{inputFile} =~ /\.zip$/) {
  open(A, "zcat $globopts{inputFile}|");
} else {
  open(A, "$globopts{inputFile}");
}

# the binary file with the data for this input file (which will be
# ignored after I pull out the first few values)

my($binfile) = "$globopts{inputFile}.bin";

unless (-f $binfile) {die "Binary file $globopts{inputFile}.bin does not exist";}

open(B, "$globopts{inputFile}.bin");

while (!eof(B)) {
  sysread(B, $out, 2);

  if (++$count%1e6 == 0) {debug("COUNT: $count");}

}



die "TESTING";

debug("LOADING BIN FILE");
my($bindata) = read_file("$globopts{inputFile}.bin");
debug("DONE LOADING BIN FILE");

die "TESTING";

# open the outfile
open(B, $globopts{outputFile})||die("Can't open output file: $!");

# first 6 rows are header lines
my(@arr);
for $i (0..5) {$arr[$i] = <A>;}

# meta data
my(%meta);
for $i (@arr) {
  $i=~s/^(.*?)\s+(.*)$//;
  $meta{$1} = $2;
}

# confirm bad value converts to 0 (or something)
unless ($meta{NODATA_value} + $globopts{dataAdd} == 0) {
  warn "NODATA_value not mapped to 0, possible error but may be OK";
}

# we adjust lower left corner latitude and longitude by turning them
# into row/col coordinates (positive and a multiple of cellsize)

# we then add 1/2 to each (and round) so they represent the lowest
# left value, which is 1/2 cellsize away in each direction from the
# corner

my($adjlat) = round(($meta{yllcorner}+90)*$globopts{dataPerDegree}+1/2);
my($adjlon) = round(($meta{xllcorner}+180)*$globopts{dataPerDegree}+1/2);

print "Lower left tile is xy: $adjlon, $adjlat\n";

# for speed, we compute the adjusted lat/lon for each row/col (we are
# 0-indexed)

my(@row2lat, @col2lon);

for ($i=$meta{nrows}-1; $i>=0; $i--) {$row2lat[$i] = $adjlat++;}
for $i (0..$meta{ncols}-1) {$col2lon[$i] = $adjlon++;}

print "Upper right tile is xy: $col2lon[$meta{ncols}-1], $row2lat[0]\n";

my($row) = 0;

while (<A>) {

  debug("ROW: $row");

  # ignore impossible latitudes with a warning
  if ($row2lat[$row] < 0 || $row2lat[$row] > $height) {
    warn "Ignoring bad latitude: $row -> $row2lat[$row]";
    next;
  }

#  my(@cols) = split(/\s+/, $_);

#  for $col (0..$#cols) {

#  my($col) = -1;

  debug("BEGIN COLSPLIT");

#  while (s/(\S+)\s*//) {

  for $col (0..$meta{ncols}-1) {

#     $colval = $1;

    my($scanner) = String::Scanf->new("%d");

    $colval = $scanner->sscanf($_);

#    debug("COLVAL: $colval");

    # ignore impossible longitudes with a warning
    if ($col2lon[$col] < 0 || $col2lon[$col] > $width) {
      warn "Ignoring bad longitude: $col -> $col2lon[$col]";
      next;
    }

    # the byte position in the mega file (n bytes per data point)
    my($byte) = $row2lat[$row]*$globopts{bytesPerData}*$width + $col2lon[$col]*$globopts{bytesPerData} + $reserve;

    if ($byte < 0 || $byte > $bytes) {
      warn "Can't write to byte $byte";
      next;
    }

    # the value to post, converted to bytes
    my($post) = $colval + $globopts{dataAdd};

    my($str) = base256($post, $globopts{bytesPerData});

    sysseek(B, $byte, 0);
    syswrite(B, $str);

#    debug("ROW/LAT: $row/$row2lat[$row], COL/LON: $col/$col2lon[$col], BYTE: ".format_number($byte).", VAL: $colval, POST: $post, STR: $str");

  }


  debug("END COLSPLIT");

  $row++;

  if ($row%100 == 0) {debug("ROW: $row");}

}

sub base256 {
  my($x, $b) = @_;

  # if not near an integer, worry
  if (abs($x - round($x)) > 0.1) {warn "Submitted value $x not integral";}

  # round it regardless
  $x = round($x);

  # make sure it's not too small
  if ($x < 0) {
    warn "Submitted value is negative, returning 0";
    return chr(0)x$b;
  }

  # make sure it's not too big
  if ($x > 2**(8*$b)-1) {
    warn "Submitted value $x too big, returning max";
    return chr(255)x$b;
  }

  my(@arr);

  for $i (1..$b) {
    push(@arr, $x%256);
    $b = floor($x/256);
  }

  return join("", map($_ = chr($_), reverse(@arr)));
}
