#!/bin/perl

# This is bc-daemon-checker.pl for bcinfo3 (writes to file, doesn't send mail)
# --stderr: write to stderr not ERR file
# --mach: name of machine and name of file for errors
# --file: use this as proclist file
# --sleep: sleep this many seconds before running (useful to avoid
# seeing multi CROND or similar for jobs that run frequently but
# briefly)

# Sections in config file:
# must: these programs must be running at all times
# may: these programs may run as long as they wish
# kill: these programs must be killed if they run too long
# memory: these programs can use as much memory as they wish
# stopped: these programs are allowed to be stopped

# TODO: add per-process memory and time limits

# TODO: make this restart failed daemons

require "/usr/local/lib/bclib.pl";

# default file is for my server
defaults("mach=bcinfo3&file=/home/barrycarter/BCGIT/BCINFO3/root/bcinfo3-procs.txt");

sleep($globopts{sleep});

# this command really does all the work
($out,$err,$res) = cache_command2("ps -wwweo 'pid ppid etime rss vsz stat args'","age=30");

# if process matches any of these, use second argument (if one exists)
# TODO: move this to conf file too?

my(%use2nd) = list2hash("/usr/bin/perl", "python", "/bin/perl",
"/usr/bin/python", "/bin/sh", "-csh", "sh");

@procs = split(/\n/,$out);
shift(@procs); # ignore header line

# TODO: make this an argument, not fixed
$all = read_file($globopts{file});
my(%proclist);

# NOTE: this not true XML
while ($all=~s%<(.*?)>(.*?)</\1>%%s) {
  my($sec,$list) = ($1,$2);
  for $i (split(/\n/,$list)) {
    if ($i=~/^\s*$/ || $i=~/^\#/) {next;}
    $proclist{$sec}{$i} = 1;
  }
}

# TODO: allow comments in must/may/kill sections

for $i (@procs) {
  # cleanup proc line and split into fields
  $i=trim($i);
  $i=~s/\s+/ /isg;
  ($pid,$ppid,$time,$rss,$vsz,$stat,$proc,$proc2,$proc3) = split(/\s+/,$i);

  # ignore [bracketed] processes because there are lots of them and
  # they all seem OK
  # TODO: is this wise?
  if ($proc=~/^\[.*\]$/) {next;}

  # use second arg? (third if second arg is an option)
  # TODO: maybe improve this
  if ($use2nd{$proc} && $proc2) {
    if ($proc2=~/^\-/) {$proc=$proc3;} else {$proc=$proc2;}
  }

  # for multiple run checking, count if/how many times proc is running
  $isproc{$proc}++;

  # report stopped processes
  if ($stat=~/T/ && !$proclist{stopped}{$proc}) {
    push(@err, "stopped.$proc ($pid)");
  }

  # processes using too much memory
  if ($rss>500000 && !$proclist{memory}{$proc}) {
    push(@err, "mem.$proc ($pid)");
  }

  # if the proc must be running or may run indefinitely, stop here
  # Note: programs that must run are also checked later

  if ($proclist{must}{$proc} || $proclist{may}{$proc}) {next;}

  # any process may run for up to 300s
  my($stime) = pstime2sec($time);
  if ($stime < 300) {next;}

  # am I allowed to kill this process?
  if ($proclist{kill}{$proc}) {
    # if I am allowed to kill it and it's been running for 10x its
    # allowed time, something is wrong
    if ($stime>3000){push(@err, "10x.$proc ($pid)");next;}
    # kill it
    system("kill $pid");
  }

  # process is running long, and is neither permitted nor required to
  # run forever, but I'm not allowed to kill it.... so whine
  push(@err, "toolong.$proc ($pid)");
}

# confirm all "must" processes are in fact running

for $i (sort keys %{$proclist{must}}) {
  if ($isproc{$i}) {next;}
  push(@err, "notrunning.$i");
}

# multirun checking
for $i (keys %isproc) {
  if ($isproc{$i}>=2 && !$proclist{multi}{$i}) {
    push(@err, "multi.$i");
  }
}

map($_="$globopts{mach}.$_",@err);

# write errors to file EVEN IF empty (since I plan to rsync error
# file, and rsync won't remove deleted files except with special
# option)
if ($globopts{stderr}) {
  print STDERR join("\n",@err),"\n";
} else {
  write_file_new(join("\n",@err),"$ENV{HOME}/ERR/$globopts{mach}.err");
}

=item pstime2sec($time)

Conver the time given by ps (like "88-22:29:29") to seconds

=cut

sub pstime2sec {
  my($time) = @_;
  if ($time=~/^(\d+)\-(\d{2}):(\d{2}):(\d{2})$/) {return $1*86400+$2*3600+$3*60+$4;}
  if ($time=~/^(\d{2}):(\d{2}):(\d{2})$/) {return $1*3600+$2*60+$3;}
  if ($time=~/^(\d{2}):(\d{2})$/) {return $1*60+$2;}
  warn("Can't convert $time into seconds");
  return 0;
}
