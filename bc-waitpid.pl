#!/bin/perl

# Wait until a given process has stopped + then report
# --nox: do not send xmessage, just end
# --message: add this to standard message

require "/usr/local/lib/bclib.pl";

my($pid) = @ARGV;
unless ($pid) {die "Usage: $0 pid|string";}
defaults("message=No message");

# if argument is string, use pgrep
unless ($pid=~/^\d+$/) {
  debug("PGREPPING: $pid");
  my(@procs) = `pgrep $pid`;

  if ($#procs==-1) {die "No procs matching: $pid";}
  # TODO: proceed here with "first" process pgrep returns
  if ($#procs>0) {die "More than 1 proc matchines: $pid";}
  $pid = $procs[0];
  chomp($pid);
}

# determine process name
my(@arr) = `ps -p $pid`;
$arr[1]=~s/^\s+//;
my(@proc) = split(/\s+/, $arr[1]);
my($name) = $proc[3];

while (!system("ps -p $pid > /dev/null")) {sleep 5;}

unless ($globopts{nox}) {system("xmessage '$pid ($name) is done: $globopts{message}'&");}
