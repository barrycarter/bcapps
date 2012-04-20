#!/bin/perl

# Confirms daemons are running and prevents other programs from
# running too long (eg, a long 'curl' run can hang a program waiting
# for it to end; timed-run would be another solution)

# Runs from cron (so doesn't need to be in @must below)

push(@INC,"/usr/local/lib");
require "bclib.pl";

# this command really does all the work
($out) = cache_command("ps -www -ax -eo 'pid etime rss vsz args'","age=30");

@procs = split(/\n/,$out);
shift(@procs); # ignore header line

# TODO: turn this into an external file list or something

# processes that MUST always be running (I should be able to trim
# down this list?)

# NOTE: full path varies because of the way these procs start

@must = (
	 "init", "syslogd", "klogd", "/usr/sbin/sshd", "ntpd",
	 "/usr/libexec/mysqld", "/usr/libexec/postfix/master", "qmgr",
	 "crond", "/usr/sbin/atd", "/sbin/mingetty",
	 "/usr/local/bin/bc-voronoi-temperature.pl",
	 "/usr/local/bin/bc-delaunay-temperature.pl",
	 "/usr/local/bin/bc-metar-db.pl", 
	 "/usr/local/bin/bc-gocomics-comments.pl",
	 "/usr/sbin/lighttpd", "/usr/local/bin/php-cgi",
	 "teenydns", "pickup"
	);

# processes that MAY run forever but aren't required to do so (choices
# like /sbin/udevd are weird, but I don't really care if hotplug is
# working?)

# "sshd:" represents a specific login; the main daemon must always
# run, but the client daemon doesn't have to always run (but can if it
# wants)

@may = (
	"SCREEN", "screen", "-csh", "sh", "/bin/sh", "/sbin/udevd",
	"/usr/libexec/gam_server", "sshd:", "-bin/tcsh"
	);

# Processes on this list must be killed if they run over 5m
@kill = (
	 "curl"
	 );

# easier as hashes
%must = list2hash(@must);
%may = list2hash(@may);
%kill = list2hash(@kill);

for $i (@procs) {
  # cleanup proc line and split into fields
  $i=trim($i);
  $i=~s/\s+/ /isg;
  ($pid, $time, $rss, $vsz, $proc, $proc2, $proc3) = split(/\s+/,$i);

  # ignore [bracketed] processes (TODO: why?)
  if ($proc=~/^\[.*\]$/) {next;}

  # for perl/xargs/python/ruby, the second arg tells what the process really is
  if ($proc=~m%/perl$%||$proc eq "xargs"||$proc=~m%/python$%||$proc=~m%(^|/)ruby$%) {
    $proc=$proc2;
  }

  # really ugly HACK: (for "perl -w") [can't even do -* because of -tcsh]
  if ($proc=~/^\-w$/) {$proc=$proc3;}

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

  # any process permitted to run up to 5m
  # TODO: specific limits for procs where 5m is wrong
  if ($sec<=300) {next;}

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

for $i (sort keys %MUST) {
  if ($isproc{$i}) {next;}
  push(@err, "$i: not running, but is required");
}

debug(@err);

