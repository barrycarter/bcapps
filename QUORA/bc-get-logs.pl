#!/bin/perl

# attempts to efficiently obtain quora log entries, similar to how I
# download fetlife data (ie, using large single connections, not many
# small ones)

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

# TODO: don't hardcode this (150M = as of 7 Jun 2016)
my($start) = 171430000;
# TODO: this is just testing, in reality this will keep running
my($end) = 173677964;

# which ones do I already have (somewhat extensive search)

# TODO: this list is overextensive even after filtering below, not
# everything here is a log entry

my($out,$err,$res) = cache_command2("find /home/barrycarter/QUORA/ -follow -name '[0-9]*'", "age=3600");

for $i (split(/\n/, $out)) {

  # just the filename and remove .html and .html.bz2
  $i=~s%^.*/%%;
  $i=~s/\.html//;
  $i=~s/\.bz2//;

  # should now be all digits
  unless ($i=~/^\d+$/) {next;}

  # TODO: check to see I actually have these, not just empty/error
  # files like 'too many connections' or 2843b errors

  $done{$i} = 1;

}

for $i (sort {$a <=> $b} keys %done) {print "$i\n";}

# command I use to download log entries
my($cmd) = "curl -H 'Cookie: m-b=$private{quora}{cookie}' -L --compress --socks4a 127.0.0.1:9050";

# dir where I store these
my($logdir) = "/home/barrycarter/QUORA/LOG";
dodie("chdir('$logdir')");

# the longest command line (it's actually bigger than this, but this
# is a safe value)
my($maxlen) = 100000;

# TODO: if some come out "blank", stop for n seconds

# total length so far (start with infinity to force command at start)
my($len) = +Infinity;

# TODO: not sure if writing to file is a good idea here
dodie('open(B,">cmds.sh")');

# eternal loop
for (;;) {

  # TODO: should I increment a different var?
  if ($start++ > $end) {last;}

  if ($done{$start}) {next;}

  debug("ADDING: $start");

  $str = "-o $start.html https://www.quora.com/log/revision/$start ";
  $len += length($str);

  if ($len <= $maxlen) {print B $str; next;}

  # length too long, so print new line
  $str = "\n$cmd $str";
  $len = length($str);
  print B $str;
}

dodie('close(B)');



