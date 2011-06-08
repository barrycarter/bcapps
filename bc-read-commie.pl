#!/bin/perl

# Reads Commodore floppy disk data in .D64 format
# TODO: does not work very well at the moment

require "bclib.pl";

# read the .D64 file
($all,$file) = cmdfile();
$|=1;
# start on the directory sector
($track,$sector) = (18,1);

# loops constantly until user ends program
for (;;) {

  # read the current block
  $block = read_chunk($all,$track,$sector);

  # first two bytes x,y say "block continued on track x, sector y"
  # if x is 0, y gives number of bytes in this sector that are valid
  $block=~s/^(.)(.)/"<".ord($1)."><".ord($2).">"/iseg;

  # major kludge: use <dec> code for tracks 18/19, ^char code for others
  if ($track == 18 || $track == 19) {
    # first, convert <130><t><s> in dirs
    $block=~s/(\201|\202)(.)(.)/"T".ord($2).",S".ord($3).": "/iseg;

    # mysterious character 160 is turned into underscore
    $block=~s/\240/_/isg;

    # big chunks of nulls are turned into newlines
    $block=~s/\000+/\n/isg;

    # display nonprintable characters decently
    $block=~s/([^ -~\n])/"<".ord($1).">"/iseg;
  } else {
    # for normal blocks, convert Commodore ASCII to regular ASCII
    $block=~s/([\000-\037])/chr(ord($1)+96)/iseg;
  }

  print "$block\n";

  # ask user for next track/sector
  print "Enter track sector\n";
  ($track,$sector) = split(/\s+/, <STDIN>);

}

# convert track/sector to byte offset in D64 file

sub byte {
  my($track, $sector) = @_;
  if ($track<=17) {return 256*(($track-1)*21+$sector);}
  if ($track>=18 && $track<=24) {return (357+($track-18)*19+$sector)*256;}
  if ($track>=25 && $track<=30) {return (490+($track-25)*18+$sector)*256;}
  if ($track>=31) {return (598+($track-31)*17+$sector)*256;}
}

# read an entire "chunk" of a commodore disk image, using first two
# bytes of a track sector to either follow to the next track/sector or
# only read the first n bytes of a given sector

sub read_chunk {
  my($image,$track,$sector,%rechash) = @_;

  # where in the disk image is this track/sector?
  my($loveat) = byte($track,$sector);

  # have we seen this track/sector before? (avoids infinite loops)
  if ($rechash{$loveat}) {return "";}
  $rechash{$loveat} = 1;

  # get the next track/sector from the first two bytes of this one
  # <h>My entry for "most complex looking code that does very little"</h>
  my($ntrack,$nsector) = map(ord($_),split(//,substr($image,$loveat,2)));

  # if $ntrack is 0, only first $nsector bytes here are valid
  if ($ntrack == 0) {
    return substr($image,$loveat+2,$nsector)."\n";
  }

  # otherwise, entire sector is valid an concatenate next
  return substr($image,$loveat+2,256).read_chunk($image,$ntrack,$nsector,%rechash);
}
