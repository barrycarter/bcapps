#!/bin/perl

# Alert all comicssherpa.com authors to an experimental RSS service

# this is an example of how I work a small project

require "bclib.pl";

debug(get_strips());

# experimenting with extreme subroutining

# obtain the list of comicssherpa strips, return their 'cs' codes
sub get_strips {
  my(@res);
  # the page that lists all sherpa strips (long cache: this rarely changes)
  my($page) = cache_command("curl http://www.comicssherpa.com/site/home.html", "age=86400");

  # find everything like http://www.comicssherpa.com/site/feature?uc_comic=csiit
  while ($page=~s/uc_comic=(.*?)\"//) {
    push(@res, $1);
  }

  return @res;
}

# find the URL that shows a given strips comments 
