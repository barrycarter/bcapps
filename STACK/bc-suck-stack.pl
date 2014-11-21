#!/bin/perl

# Attempts to suck down all comments/questions/answers/etc I've made
# on stackexchange.com sites; you will probably want to modify it for
# your own userid

# TODO: does NOT work with hidden comments "click here to show..."
# TODO: does NOT work with multipage answers
# TODO: does NOT download meta

require "/usr/local/lib/bclib.pl";

# My user page on stackexchange.com is
# http://stackexchange.com/users/144803/barrycarter; that's where I
# get the number below

my($id) = 144803;

# use accounts page to find all my ids (caching most calls because
# these pages change rarely and I will access them frequently while
# testing)

# Note: this URL will auto redirect (thus "-L") to one that includes
# my username ("barrycarter"), but we don't actually need the username
# to access it

my($out,$err,$res) = cache_command2("curl -L 'http://stackexchange.com/users/$id/barrycarter?tab=accounts'", "age=86400");

my(%siteid,%max,%urls,%cmds);

while ($out=~s%http://(.*?)/users/(\d+)%%) {$siteid{$1} = $2;}

# download activity per site (multiple pages possible)

for $i (keys %siteid) {
  my($out,$err,$res) = cache_command2("curl -L '$i/users/$siteid{$i}/?tab=activity'", "age=86400");

  # number of pages (storing this in hash for later use?)
  my($baseurl);
  while ($out=~s%href="(.*?)page=(\d+)"%%) {
    ($baseurl, my($page)) = ($1,$2);
    if ($page > $max{$i}) {$max{$i} = $page;}
  }

  # restore amps
  $baseurl=~s/&amp;/&/g;

  # download all pages and find all links
  for $j (1..$max{$i}) {
    my($out,$err,$res) = cache_command2("curl -L 'http://$i${baseurl}page=$j'", "age=86400");
    while ($out=~s%href="/questions/(\d+)%%) {
      # use hash because duplicates do exist (map to site for later)
      $urls{$1}=$i;
    }
  }
}

for $i (keys %urls) {
  # put in /usr/local/etc/STACK/sitename/questionnumber
  my($dname) = "/usr/local/etc/STACK/$urls{$i}";
  unless (-d $dname) {system("mkdir -p $dname");}
  my($fname) = "$dname/$i";

  # already exists? skip
  # TODO: re-download older URLs as they might have changed (-M)
  if (-f $fname) {next;}

  # dont run commands here in case I want to parallel them later or something
  $cmds{"curl -Lo $fname 'http://$urls{$i}/questions/$i'"} = 1;
}

for $i (sort keys %cmds) {
  debug("RUNNING: $i");
  system($i);
}



