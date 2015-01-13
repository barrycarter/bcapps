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
  my(@colons) = split(/^([a-z-]{1,15}:)/im, $all);

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

    # if header is date, set new date
    if ($h=~/date/i) {$date = $v; next;}

    # value separator for wiki is plus not comma (except for dates)
    $v=~s/,\s*/+/g;

    # otherwise, associate data with date
#    debug("$h -> $v");
    $data{$date}{$h} = $v;
  }
}

# now, put into format for wiki

for $i (keys %data) {
  debug("I: $i");

  # TODO: this is really ugly: change the year to 1970 so str2time works
  $i2 = $i;
  $i2 =~s/(\d{4})/1970/;
  my($d) = strftime("$1-%m-%d", localtime(str2time($i2)+43200));

  my(@arr);

  # chunks for each key/val pair
  for $j (keys %{$data{$i}}) {
    push(@arr, "[[".lc($j)."::$data{$i}{$j}]]");
  }

  debug("$d",@arr);

}

