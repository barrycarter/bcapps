#!/bin/perl

# Given craigslist management URLs (like
# https://post.craigslist.org/manage/123/xyz), renews the posting if
# possible [the URLs are the ones that come AFTER redirection!]

require "/usr/local/lib/bclib.pl";

while (<>) {

  # ignore comments and empty lines
  if (/^\#/ || /^\s*$/) {next;}

  # obtain page
  my($out,$err,$res) = cache_command2("curl -k $_","age=3600");
  my($form);

  # find renew form
  while ($out=~s%<form[^>]*?>(.*?)</form>%%s) {
    $form = $1;
    debug("FORM: $form");
    if ($form=~/renew/s) {last;}
  }

  # find the crypt which is the only thing actually needed
  unless ($form=~s/name="crypt"\s+value="(.*?)"//) {
    warn "Cannot renew: $_";
    next;
  }

  my($crypt) = $1;

  my($cmd) = "curl -k -d 'action=renew&crypt=$crypt' $_";

  my($out,$err,$res) = cache_command2($cmd, "age=3600");

  debug("OUT: $out");
}


