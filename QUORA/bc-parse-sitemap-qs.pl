#!/bin/perl

# Parses https://quora.com/sitemap/questions which does NOT require a
# username/password, and further digs into log entries for each
# question

require "/usr/local/lib/bclib.pl";

# TODO: cache less in production?
# TODO: suck https://www.quora.com/sitemap/recent too?
# TODO: and https://www.quora.com/sitemap/recent?page_id=9 eg?
# TODO: grab  /sitemap/questions?page_id=10 up to page 10

my($out,$err,$res);
my(%urls);

dodie("chdir('/var/tmp/quora')");

# TODO: check write perms here?
unless (-d "/var/tmp/quora") {die "Create /var/tmp/quora";}

for $i (1..10) {
  for $j ("questions", "recent") {

    ($out,$err,$res) = cache_command2("curl -L 'https://quora.com/sitemap/$j?page_id=$i'", "age=86400");

    while ($out=~s/href="(.*?)"//s) {
      my($url) = $1;
      unless ($url=~/quora\.com/) {next;}
      $urls{$url}{"page"} = $i;
      $urls{$url}{"type"} = $j;
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
  parse_metalog($out);

  unless (-f "$fname.html") {
    debug("OBTAINING: $i.html");
    ($out, $err, $res) = cache_command2("curl -Lo '$fname.html' '$i'");
  } else {
    $out = read_file("$fname.html");
  }

  parse_question($out);
}

for $i (sort {$a <=> $b} keys %hash) {
  debug("$i -> $hash{$i}");
}

# program-specific subroutine to parse metalogs

sub parse_metalog {
  my($mlog) = @_;

  # TODO: currently writing to global %hash, but reconsider
  # my(%hash);

  while ($mlog=~s%<p class="log_action_bar">(.*?)</p>%%s) {
    my($loge) = $1;
    $loge=~s%/log/revision/(\d+)%%;
    my($rev) = $1;
    $loge=~s%</span>(.*?)$%%;
    # TODO: what timezone is this? assuming GMT for now
    $hash{$rev} = str2time($1);
  }

  # TODO: capture render time of page

#  while ($mlog=~s%<a href="(.*?)">Answer</a> added by .*?href="/profile/(.*?)"%%) {
#    debug("ALPHA: $1 $2");
#  }

  while ($mlog=~s%<a href="([^\"]*?)">Answer</a> added by%%) {
    debug("ALPHA: $1");
  }

  while ($mlog=~s%>Question added by (.*?)</span>%%) {
    debug("BETA: $1");
  }

  while ($mlog=~s%href="/topic/(.*?)"%%) {
    debug("GAMMA: $1");
  }

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
