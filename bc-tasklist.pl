#!/bin/perl

# A trivial "task list" that looks at a directory and lists files
# (matching *.task) oldest to newest (oldest = task that hasn't been
# done for longest) and lets me mark when I'm working on a task and
# when I've finished

# Usage: $0 (list|start/begin|end) [task]

# TODO: all task "aging" so some tasks can be older and still ok

# TODO: this may be combinable with nagyerass stuff

# --directory: the directory where the tasks are located

require "/usr/local/lib/bclib.pl";
defaults("directory=/usr/local/etc/tasks");
dodie("chdir('$globopts{directory}')");

# action depends on first parameter
my($action, $task) = @ARGV;

debug("ACTION: $action, TASK: $task");

if ($action=~/^(start|begin)$/i) {

  unless (-f 


die "TESTING";

my($out, $err, $res) = cache_command2("find . -iname '*.task*' -printf \'%T\@ %f\n\' | sort -n");



debug("OUT: $out");



