#!/bin/perl

# Alert all comicssherpa.com authors to an experimental RSS service

# this is an example of how I work a small project

require "bclib.pl";

send_comment();
die "TESTING";

# surl = Sherpa URL, gurl = gocomics.com URL
%name2surl = get_strips();
%name2gurl = get_gocomics();

# debug(sort keys %name2gurl);
# debug("SPLIT");
# debug(sort keys %name2surl);

# determine the gurl of each surl using transitivity

for $i (sort keys %name2surl) {
#  debug("$i, $name2gurl{$i}");
  $surl2gurl{$name2gurl{$i}} = $name2surl{$i};
#  debug("$i s-> $name2surl{$i}");
#  debug("$i g-> $name2gurl{$i}");
}

# debug("ALPHA",%surl2gurl);

# now, get the db.94y.info URL that yields the recent comments for a
# given strip

for $i (sort keys %surl2gurl) {
  debug("I: $i");
  # got this by using sniffit
  $post = "query=SELECT+body%2C%22http%3A%2F%2Fgocomics.com%2F%22%7C%7Cstrip%7C%7C%22%2F%22%7C%7Cyear%7C%7C%22%2F%22%7C%7CSUBSTR%28%220%22%7C%7Cmonth%2C-2%2C2%29%7C%7C%22%2F%22%7C%7CSUBSTR%28%220%22%7C%7Cdate%2C-2%2C2%29+AS+url+FROM+comments+WHERE+strip%3D%27$i%27+ORDER+BY+timestamp+DESC+LIMIT+50+";
  # do NOT redirect here, we want the Location: URL
  $cmd = "curl -D - -d '$post' http://gocomics.db.barrycarter.info/";
  ($out,$err,$res) = cache_command($cmd,"age=86400");

  # find the redirect
  $out=~/Location: (.*?)\n/s;
  $loc = $1;
  debug("LOC: $loc");
}

# experimenting with extreme subroutining

# send an email via gocomics to author
sub send_comment {
  my($strip) = @_;

  # TODO: set feature_name, urlencode $msg

  my($msg) = << "MARK";

Replies to rssman\@barrycarter.info (if you just hit 'R'eply, it won't
get to me).

MARK
;

  my($cmd) = "curl -d 'DETAILS=my+message&FORM=Contact+Us&SUBMIT=Submit&email=rssman\@barrycarter.info&feature=csiit&feature_name=Rose+is+Hosed' 'http://www.comicssherpa.com/site/feedback-action'";
  system($cmd);
}

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
  while ($page=~s%/(.*?)\" class=\".*?\">(.*?)</a>%%) {
    $res{$2} = $1;
  }

  return %res;
}

# find the URL that shows a given strips comments 
