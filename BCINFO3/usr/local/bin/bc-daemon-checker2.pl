#!/bin/perl

# This is bc-daemon-checker.pl for bcinfo3 (writes to file, doesn't send mail)
# --stderr: write to stderr not ERR file
# --file: use this as proclist file
# Sections in config file:
# must: these programs must be running at all times
# may: these programs may run as long as they wish
# kill: these programs must be killed if they run too long
# TODO: make this restart failed daemons

require "/usr/local/lib/bclib.pl";

# default file is for my server
defaults("file=/home/barrycarter/BCGIT/BCINFO3/root/bcinfo3-procs.txt");

# this command really does all the work
($out,$err,$res) = cache_command2("ps -www -ax -eo 'pid etime rss vsz args'","age=30");

@procs = split(/\n/,$out);
shift(@procs); # ignore header line

# TODO: make this an argument, not fixed
$all = read_file($globopts{file});
my(%proclist);

# NOTE: this not true XML
while ($all=~s%<(.*?)>(.*?)</\1>%%s) {
  my($sec,$list) = ($1,$2);
  for $i (split(/\n/,$list)) {
    if ($i=~/^\s*$/) {next;}
    debug("*$sec* *$i*");
    $proclist{$sec}{$i} = 1;
  }
}

# TODO: allow comments in must/may/kill sections

for $i (@procs) {
  # cleanup proc line and split into fields
  $i=trim($i);
  $i=~s/\s+/ /isg;
  ($pid, $time, $rss, $vsz, $proc, $proc2, $proc3) = split(/\s+/,$i);

  # ignore [bracketed] processes (TODO: why?)
#  if ($proc=~/^\[.*\]$/) {next;}

  debug("BETA:",$proclist{may}{"/sbin/init"},$proclist{may}{$proc});

  debug("RPOC: *$proc*");
  # if process name is perl, use $proc2
  if ($proc eq "/bin/perl") {$proc=$proc2;}

  debug("GAMMA:",$proclist{may}{"/sbin/init"},$proclist{may}{$proc});

#  debug("PROC NOW: *$proc*");

  # strip directory information
#  $proc=~s%^.*/%%;

  # if the proc must be running or may run indefinitely, stop here
  # Note: programs that must run are also checked later
#  debug("PROCALPH: *$proc*, $procinfo{may}{$proc}", $procinfo{may}{"/sbin/init"});

  if ($proclist{must}{$proc} || $proclist{may}{$proc}) {next;}

  debug("DELTA:",$proclist{may}{"/sbin/init"},$proclist{may}{$proc});

  debug("FAIL ($proc),",$procinfo{must}{$proc}, $procinfo{may}{$proc},$procinfo{may}{"/sbin/init"});

  debug("LINE: $proc $proc2 $proc3","PROC: $proc");

  $isproc{$proc} = 1;

  warn "TESTING";
  next;

  # for perl/xargs/python/ruby/sh, the next non-option arg tells what the process really is
  if ($proc=~m%/perl$%||$proc eq "xargs"||$proc=~m%/python$%||$proc=~m%(^|/)ruby$%||$proc=~m%^/bin/sh$%||$proc=~m%^\-csh$%) {

    # TODO: this is imperfect
    if ($proc2=~/^\-/) {
      $proc=$proc3;
    } else {
      $proc=$proc2;
    }
  }

  # really ugly HACK: (for "perl -w") [can't even do -* because of -tcsh]
  if ($proc=~/^\-w$/) {$proc=$proc3;}

#  debug("PROC: $proc");
  
  # can't do much w/ defunct procs
  if ($i=~/<defunct>/) {next;}

  # if this program is permitted to run forever, but not required, stop here
  # TODO: add check if process is on two lists?
  if ($may{$proc}) {next;}

  # if this process must run, record it and continue
  if ($must{$proc}) {
    $isproc{$proc}=1;
    next;
  }

  # how long has program been running?
  if ($time=~/^(\d+)\-(\d{2}):(\d{2}):(\d{2})$/) {
    $sec = $1*86400+$2*3600+$3*60+$4;
  } elsif ($time=~/^(\d{2}):(\d{2}):(\d{2})$/) {
    $sec = $1*3600+$2*60+$3;
  } elsif ($time=~/^(\d{2}):(\d{2})$/) {
    $sec = $1*60+$2;
  } else {
    warnlocal("Can't convert $time into seconds");
    next;
  }

  # processes are born 13:42 old (no idea why), this compensates
  # TODO: HACK: figure this out
  $sec-=822;

  # any process permitted to run up to 5m
  # bumped to 10m on 20 Jan 2014
  # TODO: specific limits for procs where 5m is wrong
  if ($sec<=600) {next;}

  # if I'm allowed to kill this process, do so now
  if ($kill{$proc}) {
    system("kill $pid");
    next;
  }

  # process is running long, and is neither permitted nor required to
  # run forever, but I'm now allowed to kill it.... so whine

  push(@err, "$proc ($pid): running > 300s, but no perm to kill");
}

# confirm all "must" processes are in fact running

for $i (sort keys %{$proclist{must}}) {
  if ($isproc{$i}) {next;}
  push(@err, "$i: not running, but is required");
}

# HACK: tell where err is coming from
map($_="bcinfo3: $_",@err);

die "TESTING";

# write errors to file EVEN IF empty (since I plan to rsync error
# file, and rsync won't remove deleted files except with special
# option)
if ($globopts{stderr}) {
  print STDERR join("\n",@err),"\n";
} else {
  write_file_new(join("\n",@err),"$ENV{HOME}/ERR/bcinfo3.err");
}

