#!/bin/perl

# Alert all comicssherpa.com authors to an experimental RSS service

# this is an example of how I work a small project

require "bclib.pl";

# send_comment();
# die "TESTING";

# surl = Sherpa URL, gurl = gocomics.com URL
debug("ALPHA");
%name2surl = get_strips();
debug("ALPHA2");
%name2gurl = get_gocomics();
debug("ALPHA3");

# debug(sort keys %name2gurl);
# debug("SPLIT");
# debug(sort keys %name2surl);

# the gurl of each surl using transitivity and surl2name using inverse

for $i (sort keys %name2surl) {
  $surl2gurl{$name2gurl{$i}} = $name2surl{$i};
  debug("$i -> $name2surl{$i}");
  $surl2name{$name2surl{$i}} = $i;
}

debug("SURL2NAME",%surl2name);

# debug("ALPHA",%surl2gurl);

# now, get the db.94y.info URL that yields the recent comments for a
# given strip

# randomize for best testing
@strips = keys %surl2gurl;
@strips = randomize(\@strips);

for $i (@strips) {
  # got this by using sniffit
  $post = "query=SELECT+body%2C%22http%3A%2F%2Fgocomics.com%2F%22%7C%7Cstrip%7C%7C%22%2F%22%7C%7Cyear%7C%7C%22%2F%22%7C%7CSUBSTR%28%220%22%7C%7Cmonth%2C-2%2C2%29%7C%7C%22%2F%22%7C%7CSUBSTR%28%220%22%7C%7Cdate%2C-2%2C2%29+AS+url+FROM+comments+WHERE+strip%3D%27$i%27+ORDER+BY+timestamp+DESC+LIMIT+50+";
  # do NOT redirect here, we want the Location: URL
  $cmd = "curl -D - -d '$post' http://gocomics.db.barrycarter.info/";
  ($out,$err,$res) = cache_command($cmd,"age=86400");

  # find the redirect (removing newline)
  $out=~/Location: (.*?)\n/s;
  $loc = $1;
  $loc=~s/\r//isg;
  $location{$i} = $loc;

  debug("L: $location{$i}");
  send_comment($i);

#  if (++$count>=0) {die "TESTING";}

}

die "TESTING";

# experimenting with extreme subroutining

# send an email via gocomics to author
sub send_comment {
  my($strip) = @_;
  debug("STRIP: $strip");
  my($code, $name) = ($surl2gurl{$strip}, $surl2name{$surl2gurl{$strip}});
  debug("CODE: $code, NAME: $name");

  # TODO: set feature_name, urlencode $msg

  my($msg) = << "MARK";



Gocomics.com doesn't send you an email when someone comments on your
comic strip, so I've now created a free experimental RSS feed for
${name}'s comments at:

$location{$strip}rss.pl

You can see the recent comments in table form at:

$location{$strip}

If you want to receive an email everytime your strip receives a
comment, just let me know.

Comments/questions to rssman\@barrycarter.info

REMINDER: Be sure to send replies to rssman\@barrycarter.info

Do NOT hit 'R'eply, since that won't work.

MARK
;

  debug("MSG: $msg");
  $msg = urlencode($msg);
  $name = urlencode($name);

  # TODO: feature=$strip
  my($cmd) = "curl -d 'DETAILS=$msg&FORM=Contact+Us&SUBMIT=Submit&email=rssman\@barrycarter.info&feature=$code&feature_name=$name&uc_full_date=RSS+Feed' 'http://www.comicssherpa.com/site/feedback-action'";
  debug("CMD: $cmd");
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
