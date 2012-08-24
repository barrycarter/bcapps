#!/bin/perl

# quick and dirty script to grab and cache the 'date' pages on wikipedia

require "/usr/local/lib/bclib.pl";
dodie('chdir("/home/barrycarter/BCGIT/TIMELINE")');

for $i (1..12) {
  for $j (1..31) {
    # note: this picks up impossible dates like June 31st, but I'm OK w that
    # wow, these impossible dates actually have non-trivial pages!

    $page = urlencode("$months[$i] $j");
    $outfile = "$months[$i]$j";
    debug($outfile);
    if (-f $outfile) {next;}

    # in theory, could use parallel, but only 366 of them
    ($out, $res, $err) = cache_command("curl -o $outfile 'http://en.wikipedia.org/w/api.php?format=xml&action=query&titles=$page&prop=revisions&rvprop=content'");
  }
}

# now to parse (couldve done this all in one loop, but nah)

for $i (1..12) {
  for $j (1..31) {
    # TODO: TESTING!
#    unless ($i==10&&$j==1){next;}

    debug("PARSING: $months[$i]$j");
    $data = read_file("$months[$i]$j");

#    warn("TESTING");
#    if (++$count>1) {last;}
#    if ($i>1) {last;}

    # currently only doing births/deaths, not events (the most important)

    # grab births/deaths (assumes next session exists, maybe bad)

    for $m ("births","deaths","events") {
      $data=~s/==\s*$m\s*==(.*?)==/==/is;
      $births = $1;
      @births=split(/\n/, $births);

      # split into lines
      for $k (@births) {
	if ($k=~/^\s*$/) {next;}
	debug("DOING: $k");
	# strip leading star and get date
	unless ($k=~s/^[\*|\~]\s*\[*(\d+)\]*\s*//) {next;}
	$date = $1;
	# remove crap up to persons name/link
	unless ($k=~s/^.*?\[/\[/) {next;}

	# drop anything after newline
	$k=~s/\n.*$//isg;

	# convert apos to double apos for sqlite3
	$k=~s/\'/''/isg;

	# get long and short of it
	$longname = $k;
	# first [[thing]] is taken
	$longname=~/\[\[(.*?)\]\]/;
	$shortname = $1;

	# for events, shortname generated above is bad
	if ($m eq "events") {$shortname=$longname;}

	$type = uc($m);
	# realdate will be determined later
	push(@queries, "INSERT OR IGNORE INTO events 
(stardate, shortname, longname, type) VALUES
($date*10000+$i*100+$j, '$shortname', '$longname', '$type');");
    }
}
  }
}


print "BEGIN;\n";
# TODO: this is only for right now
print "DELETE FROM events;\n";
print join("\n", @queries);
print "\nCOMMIT;\n";

=item schema

CREATE TABLE events (
 stardate, -- as y*mmdd.hhmmss (for human users)
 shortname, -- shortname of the event
 longname, -- longname of the event (optional)
 realdate, -- date as decimal year (more useful format)
 type -- birth|death|etc
);

-- no dupes, but this may be overkill?
CREATE UNIQUE INDEX i1 ON events(stardate,shortname,type);

=cut
