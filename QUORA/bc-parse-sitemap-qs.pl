#!/bin/perl

# Parses https://quora.com/sitemap/questions which does NOT require a
# username/password, and further digs into log entries for each
# question

require "/usr/local/lib/bclib.pl";

# TODO: cache less in production?

my($out,$err,$res);
my(%urls);

# global variable to keep track of revision time
my(%rev2time);

# this is just for testing, though could be a global
my($maxcount) = Infinity;
my($maxpage) = Infinity;
my($count);

dodie("chdir('/var/tmp/quora')");

# this one parsing poorly, copied to temp.html

my(%hash) = %{parse_metalog(read_file("/home/barrycarter/temp.html"))};

debug(dump_var("hash", \%hash));

die "TESTING";

# TODO: check write perms here?
unless (-d "/var/tmp/quora") {die "Create /var/tmp/quora";}

for $i (1..10) {

  if ($maxpage && $i>$maxpage) {last;}

  for $j ("questions", "recent") {

    ($out,$err,$res) = cache_command2("curl -L 'https://quora.com/sitemap/$j?page_id=$i'", "age=86400");

    while ($out=~s/href="(.*?)"//s) {
      my($url) = $1;
      unless ($url=~/quora\.com/) {next;}
      $urls{$url}{"page"} = $i;
      $urls{$url}{"type"} = $j;
      if ($maxcount && $count++ > $maxcount) {last;}
    }
  }
}

# NOTE: this yielded 3833 URLs the first time I tried it, wow!

for $i (keys %urls) {

  my($fname) = $i;
  $fname=~s%^.*/%%;

  # hashify long filenames
  if (length($fname)>246) {
    my($hash) = sha1_hex($fname);
    $fname = substr($fname,0,200)."$hash";
  }

  # TODO: this only grabs the last page of the metalog, which should
  # be enough for my purposes, but...
  # "https://www.quora.com/What-would-be-better-for-preparing-for-JEE-Advanced/log#!n=40
  # is what I'd need for the next 40 entries

  # TODO: probably better to cache this way, but worry about staleness
  # TODO: using two loops here is sloppy, just being careful for now
  unless (-f "$fname.log") {
    debug("OBTAINING: $i/log -> $fname.log");
    ($out, $err, $res) = cache_command2("curl -Lo '$fname.log' '$i/log'");
  } else {
    $out = read_file("$fname.log");
  }

  # TODO: record page number and which list it came from too
  # techincally a metalog
  debug("PARSING: $fname.log");
  $urls{$i}{data} = parse_metalog($out);

  unless (-f "$fname.html") {
    debug("OBTAINING: $i.html");
    ($out, $err, $res) = cache_command2("curl -Lo '$fname.html' '$i'");
  } else {
    $out = read_file("$fname.html");
  }
  parse_question($out);
}

# sort by most recent revision first
my(@order) = sort {$urls{$b}{data}{minrev} <=> $urls{$a}{data}{minrev}}
  keys %urls;

for $i (@order) {

  my($topics) = join(", ", keys %{$urls{$i}{data}{topic}});
  my($ans) = join(", ", keys %{$urls{$i}{data}{answerer}});
  # this should be at most one person, but...
  my($qr) = join(", ", keys %{$urls{$i}{data}{questioner}});


print << "MARK";

Q: $i
Topics: $topics
Qr: $qr
Ar: $ans
Minrev: $urls{$i}{data}{minrev}
Maxrev: $urls{$i}{data}{maxrev}

MARK
;
}

# debug(dump_var("urls", \%urls));
# debug(%rev2time);


# program-specific subroutine to parse metalogs

sub parse_metalog {
  my($mlog) = @_;

  my(%hash);

  while ($mlog=~s%<p class="log_action_bar">(.*?)</p>%%s) {
    my($loge) = $1;
    $loge=~s%/log/revision/(\d+)%%;
    $hash{revisions}{$1} = 1;
    $loge=~s%</span>(.*?)$%%;
    $rev2time{$rev}{raw} = $1;
    $rev2time{$rev}{cooked} = str2time("$rev2time{$rev}{raw} UTC");
  }

  # compute the last touched time and the "question asked" time;
  # however, if log file is multi-page, this will just be the oldest
  # action not question asked time

  # NOTE: these are reverse sorted on the page itself, but I use a
  # hash + I prefer to explicit sort

  my(@revs) = sort {$a <=> $b} keys %{$hash{revisions}};
  $hash{minrev} = $revs[0];
  $hash{maxrev} = $revs[-1];

  # TODO: capture render time of page

  my($url);

  while ($mlog=~s%<a href="([^\"]*?)">Answer</a> added by%%) {
    $url = $1;
    $url=~s%^.*/%%;
    $hash{answerer}{$url} = 1;
  }

  while ($mlog=~s%>Question added by (.*?)</span>%%) {
    $url = $1;
    $url=~s%"/profile/(.*?)"%%;
    $hash{questioner}{$1} = 1;
  }

  while ($mlog=~s%href="/topic/(.*?)"%%) {
    $hash{topic}{$1} = 1;
  }

  return \%hash;

  # TODO: last entry should be "question asked" and need to record
  # that (if multipage, ignore?) when and by whom


  # purely out of curiousity, find "javascript" stuff
#  while ($mlog=~s/\"(.*?)\": (.*?)\,//) {debug("$1 -> $2");}

  # fewer things, but more important
#  while ($mlog=~s/\"(.id)\": (\d+)//) {debug("$1 -> $2");}

#  die "TESTING";

}

# program-specific subroutine to parse questions

sub parse_question {
  my($q) = @_;
  # TODO: everything
}
