#!/bin/perl

# tumblr_backup.py works great, but doesnt download inline images;
# this program is a trivial hack that assumes you've run
# tumblr_backup.py and then attemts to grab inline images, assuming
# you're storing blogs at /home/user/TUMBLR

require "/usr/local/lib/bclib.pl";

die "redoing entirely, trying to do mass src grep in ~/TUMBLR";

for $i (@ARGV) {

  debug("DOING: $i");

  # TODO: generalize location
  # TODO: handle errors better?
  dodie('chdir("/home/user/TUMBLR/")');

  # TODO: consider omitting $i below and auto-do for all (yikes?)
  # caching here for testing purposes, but may be useful above/beyond
  my($out, $err, $res) = cache_command2("grep -R src= $i", "age=3600");

  while ($out=~s/src="(.*?)"//) {
    debug("GOT: $1");
  }

#  debug("OUT: $out");

  # TODO: made major changes above, so caution

  die "TESTING";



  # TODO: for large tumblrs, grepping through all posts is tedious,
  # try to set up an mtime check vs last dld image or something

  open(A,"grep -R tumblr_inline .|");

  # download 10 at a time
  open(B,"| xargs -r -P 10 -n 1 curl -O");

  while (<A>) {
    while (s%"(https?://.*?)"%%) {
      my($url) = $1;
      unless ($url=~m%/(tumblr_inline.*)$%) {next;}
      my($fname) = $1;
      if (-f $fname) {
	debug("SKIPPING: $url (already dld)");
	next;}
      debug("FETCHING: $url");
      print B "$url\n";
    }
  }
  close(A);
  close(B);
}



