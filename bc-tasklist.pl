#!/bin/perl

# A trivial "task list" that looks at a directory and lists files
# (matching *.task) oldest to newest (oldest = task that hasn't been
# done for longest) and lets me mark when I'm working on a task and
# when I've finished

# Usage: $0 (list|start/begin|stop/fail|end/finish) [task]

# TODO: all task "aging" so some tasks can be older and still ok

# TODO: this may be combinable with nagyerass stuff

# --directory: the directory where the tasks are located

require "/usr/local/lib/bclib.pl";
defaults("directory=/usr/local/etc/tasks");
dodie("chdir('$globopts{directory}')");
my($out, $err, $res);

# action depends on first parameter
my($action, $task) = @ARGV;


debug("ACTION: $action, TASK: $task");

# TODO: consider nicer version of die
# TODO: subroutinize

if ($action=~/^(start|begin)$/i) {

  # does this task exist?
  unless (-f "$task.task") {die("$task: no such task");}

  # have I already started?
  if (-f "$task.task.new") {die("$task: task already started");}

  # OK, cp to .new and tell user
  ($out, $err, $res) = cache_command2("cp $task.task $task.task.new");
  
  if ($res) {die("$task: CP FAILED FOR SOME REASON");}

  print "Task started\n";

  exit(0);
}

# stop = not finishing a task (TODO: better verbiage here)

if ($action=~/^(stop|fail)$/i) {

  # does this task exist?
  unless (-f "$task.task") {die("$task: no such task");}

  # have I already started?
  unless (-f "$task.task.new") {die("task: task not started");}

  # OK, rm .new and tell user
  ($out, $err, $res) = cache_command2("rm $task.task.new");
  
  if ($res) {die("$task: CP FAILED FOR SOME REASON");}

  print "Task stopped, not completed\n";

  exit(0);
}

if ($action=~/^(end|finish)$/i) {

  # does this task exist?
  # TODO: this test can be outside the ifs?
  unless (-f "$_.task") {die("$task: no such task");}

  # can't stop what you haven't started
  # TODO: HOWEVER, do want to allow start/finish at same time
  unless (-f "$_.task.new") {die("$task: task not started");}

  # OK, resolve task and tell user
  ($out, $err, $res) = cache_command2("mv $_.task $_.task.old && mv $_.task.new $_.task");
  
  if ($res) {die("$task: MV FAILED FOR SOME REASON");}

  print "Task finished\n";

  exit(0);
}

if ($action=~/^list$/i) {

  ($out, $err, $res) = cache_command2("find . -iname '*.task*' -printf \'%T\@ %f\n\' | sort -n");

  for $i (split(/\n/, $out)) {

    my($time, $task) = split(/\s+/, $i);

    $time = strftime("%Y%m%d.%H%M%S", localtime($time));
    my($data) = read_file($task);
    chomp($data);
    $task=~s/\.task//;

    print "$time \e[1m$task\e[0m $data\n";

  }

  exit(0);

}

die("$action: not understood");

