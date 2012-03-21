#!/bin/perl

# Alert all comicssherpa.com authors to an experimental RSS service

# this is an example of how I work a small project

require "bclib.pl";

# surl = Sherpa URL, gurl = gocomics.com URL
%surl2name = get_strips();
%name2gurl = get_gocomics();

debug(sort keys %name2gurl);
debug("SPLIT");
debug(sort keys %name2surl);

# determine the gurl of each surl using transitivity

for $i (sort keys %surl2name) {
  debug("$i s-> $surl2name{$i}");
  debug("$i g-> $name2gurl{$i}");
}

# experimenting with extreme subroutining

# obtain the list of comicssherpa strips, return their 'cs' codes
sub get_strips {
  my(%res);
  # the page that lists all sherpa strips (long cache: this rarely changes)
  my($page) = cache_command("curl http://www.comicssherpa.com/site/home.html", "age=86400");
#  debug($page);

  # find everything like http://www.comicssherpa.com/site/feature?uc_comic=csiit
  while ($page=~s/uc_comic=(.*?)\">(.*?)<//) {
    $res{$2}=$1;
  }

  return %res;
}

# find all strips on gocomics.com (all sherpa comics are on
# gocomics.com, but with different URLs and no obvious way to map
# between the sherpa and gocomics URLs

sub get_gocomics {
  my(%res);
  # this site requires a user agent, sheesh
  my($page) = cache_command("curl -A 'ikinhasagent\@barrycarter.info' http://www.gocomics.com/explore/sherpa_list", "age=86400");

  # list of comics (title and URL)
  while ($page=~s%/(.*?)\" class=\"alpha_list\">(.*?)</a>%%) {
    $res{$2} = $1;
  }

  return %res;
}

# find the URL that shows a given strips comments 
