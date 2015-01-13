#!/bin/perl

# parses the text files in this directory into meta-mediawiki.pl format

require "/usr/local/lib/bclib.pl";
chdir("$bclib{githome}/PEANUTS");
my(%data);

for $i (glob "peanuts-???-????.txt") {

  debug("READING: $i");

  # read file
  $all = read_file($i);

  # each pair is header/value (dashes permitted)
  my(@colons) = split(/^([ a-z-]{1,15}:)/im, $all);

  my($date);

  # TODO: not sure why I have an extra line here
  while (scalar(@colons)>1) {
    my($h,$v) = splice(@colons,1,2);

    # cleanup here
    $h=~s/://;
    $h = trim($h);
    $v = trim($v);
    $h =~s/\s+/ /g;
    $v =~s/\s+/ /g;

    # silly unicode (could use my general routine, but this should suffice)
    $v=~s/\xe2\x80(\x99|\x98)/\'/g;
    $v=~s/\xe2\x80(\x9c|\x9d)/\"/g;
    $v=~s/\xE2\x80\x93/--/g;
    $v=~s/\xC3\xA9/e/g;

    # if header is date, set new date
    if ($h=~/date/i) {$date = $v; next;}

    # convert header to form I use (probably bad to do this here)
    if ($h=~/comments?|note|discussion/i) {$h = "notes";}
    if ($h=~/speaking/i) {$h = "character";}
    # typos
    if ($h=~/descripton/i) {$h = "description";}

    # otherwise, associate data with date
#    debug("$h -> $v");

    if ($data{$date}{$h}) {
      $data{$date}{$h} .= "+$v";
    } else {
      $data{$date}{$h} = $v;
    }
  }
}

# now, put into format for wiki
open(A,">$bclib{githome}/METAWIKI/PEANUTS/PEANUTS-pp.txt");

for $i (keys %data) {

  # TODO: this is really ugly: change the year to 1970 so str2time works
  $i2 = $i;
  $i2 =~s/(\d{4})/1970/;
  my($d) = strftime("$1-%m-%d", localtime(str2time($i2)+43200));

  my(@arr);

  # chunks for each key/val pair
  for $j (keys %{$data{$i}}) {

    my($val) = $data{$i}{$j};

    # except in description, use plus to separate, not commas
    unless ($j=~/description|notes/i) {$val=~s/\,\s*/+/g;}

    push(@arr, "[[".lc($j)."::$val]]");
  }

  print A "$d ",join(" ",@arr),"\n\n";
}

close(A);
