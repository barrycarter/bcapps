#!/bin/perl

# When you use "My Matches" on POF, there's no way to "block" a user
# from appearing on that screen, even if you don't meet the
# qualifications to message them. This script helps hide these users
# from you.

# Given a list of POF URLs (like
# http://www.pof.com/#!/viewprofile.aspx?profile_id=xxxxxxxx), AND the
# inner HTML of the mymatches page, creates a greasemonkey script that
# replaces thumbnails of those ids with blanks.

# TODO: requiring the inner HTML of my matches is painful; should be
# able to create a GM script without it

# Reference: this is how the 21st match on the list looks like (user
# id replaced by pid, URL to image partly replaced by string.jpg)

# <a href="http://www.pof.com/viewprofile.aspx?profile_id=pid" class="mi" onclick="_gaq.push(['_trackEvent', 'viewmatches', 'localmatches', 'match_21']);"><img src="pof-inner_files/string.jpg" border="0"></a>

require "/usr/local/lib/bclib.pl";

@block = split(/\n/,read_file("/home/barrycarter/pof-bad.txt"));

# create hash of ids to block
for $i (@block) {
  # get the id
  $i=~s/^.*\=//;
  $block{$i} = 1;
}

# On "My Matches", do "Frame/Save Source" or similar to get this
# can't curl it since it requires login
$inner = read_file("/home/barrycarter/Download/pof-inner.html");

# split into chunks
while ($inner=~s%profile_id=(.*?)" class="mi" onclick=".*?"><img src="pof-inner_files/(.*?).jpg"%%) {
  my($id,$url) = ($1,$2);
  # if its not an id we want to block ignore it
  unless ($block{$id}) {next;}
  debug("$id -> $url");
}


