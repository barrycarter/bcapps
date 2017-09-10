#!/bin/perl

# tumblr_backup.py works great, but doesnt download inline images;
# this program is a trivial hack that assumes you've run
# tumblr_backup.py and then attemts to grab inline images, assuming
# you're storing blogs at /home/user/TUMBLR

require "/usr/local/lib/bclib.pl";

for $i (@ARGV) {

  debug("DOING: $i");

  # TODO: generalize location
  # TODO: handle errors better?
  dodie('chdir("/home/user/TUMBLR/$i/posts")');

  # TODO: for large tumblrs, grepping through all posts is tedious,
  # try to set up an mtime check vs last dld image or something

  open(A,"grep tumblr_inline *|");

  # download 10 at a time
  open(B,"| xargs -r -P 10 -n 1 curl -O");

  while (<A>) {
    while (s%"(http://.*?)"%%) {
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



