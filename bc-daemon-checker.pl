#!/bin/perl

# Confirms daemons are running and prevents other programs from
# running too long (eg, a long 'curl' run can hang a program waiting
# for it to end; timed-run would be another solution)

push(@INC,"/usr/local/lib");
require "bclib.pl";

# this command really does all the work
($out) = cache_command("ps -www -ax -eo 'pid etime rss vsz args'","age=30");

@procs = split(/\n/,$out);
shift(@procs); # ignore header line

# TODO: turn this into an external file list or something


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

  debug("PROC: $proc");






}


