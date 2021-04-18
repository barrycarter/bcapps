#!/bin/perl

# given a spotify playlist (eg, the output of:
# curl -LO https://open.spotify.com/embed/playlist/5J9Si4NGjdbyJZorMmNoH6
# ), parses it

# NOTE: ls ?????????????????????? will list these

require "/usr/local/lib/bclib.pl";

my($all, $fname) = cmdfile();

debug("PROCESSING: $fname");

# debug("ALL: $all");

unless ($all=~s%<script id="resource" type="application/json">\s*(.*?)\s*</script>%%) {
  die "COULD NOT FIND JSON RESOURCE SECTION";
}

my($json) = $1;

# the JSON here is %-escape, fix that below

$json=~s/%([0-9a-f][0-9a-f])/chr(hex($1))/iseg;

$data = JSON::from_json($json);

# go through list of tracks

for $i (@{$data->{tracks}->{items}}) {

  # capture fields we want

  my($name) = $i->{track}{name};

  my($url) = $i->{track}{preview_url};

  # find sha1sum from url

  $url=~s%/mp3-preview/([0-9a-f]+)\?%%i;

  my($sha) = $1;

  # at this moment, we're only interested in symlinking files...

  unless (-f $sha) {
    warn("NO SUCH FILE: $sha");
    next;
  }

  # artists is a list so CSV it

  my(@artists) = ();

  for $j (@{$i->{track}->{artists}}) {
    push(@artists, $j->{name});
  }

  my($artists) = join(", ", @artists);

  # suggest symlink name

  my($sname) = "$artists - $name.mp3";

  # change true quotes to apostrophes and slashes to dashes

  $sname=~s/\"/'/g;
  $sname=~s/\//-/g;

#  debug("$sname, $sha");

  # print command to symlink

  print "ln -s $sha \"$sname\"\n";

#  debug("<TRACK>", dump_var("xx", $i), "</TRACK>");
}

# debug(dump_var("xx", $data));

# debug("JSON: $json");
