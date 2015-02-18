#!/bin/perl

# download reputation data from stackexchange; will merge this into
# bc-suck-stack or whatever

require "/usr/local/lib/bclib.pl";


getStackRep("stackoverflow.com", 354134);

# oneoff for bc-suck-stack.pl so not perldoc'd

# Given userid, site URL (like "astronomy.stackexchange.com"),
# download user reputation and put in
# /usr/local/etc/STACK/(sitename)/reputation (unless that file already
# exists)

sub getStackRep {
  my($site, $userid) = @_;

  # create destination directory unless it exists
  my($dir) = "/usr/local/etc/STACK/$site/reputation";
  unless (-d $dir) {system("mkdir -p $dir");}
  chdir($dir);

  # base url
  my($baseurl) = "https://$site/users/$userid";

  # get main page (putting page=1 for better caching)
  my($out,$err,$res) = cache_command2("curl -L '$baseurl?tab=reputation&page=1'", "age=86400");

  # get highest page
  my($page);
  while ($out=~s/".*?page=(\d+)"//) {$page = max($1,$page);}

  # go through pages, find URLs
  for $i (1..$page) {
    ($out,$err,$res) = cache_command2("curl -L '$baseurl?tab=reputation&page=$i'", "age=86400");
    # and the urls on this page
    while ($out=~s/data-load-url="(.*?post)"//s) {$urls{$1}=1;}
  }

  # download URLs
  for $i (sort keys %urls) {
    # timestamp
    $i=~m%/(\d+)\?sort=post%;
    my($fname) = $1;
    if (-f $fname) {next;}
    # no cache here, since only dl once
    ($out,$err,$res) = cache_command2("curl -L -o $fname 'https://$site$i'");
  }
}
