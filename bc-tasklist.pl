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
my($dir) = $globopts{directory};
dodie("chdir('$dir')");

my($out, $err, $res);

# action depends on first parameter
my($action, $task) = @ARGV;

# TODO: if I allow parameters for list, this next check could be ugly
# TODO: should this really be --action=action --task=task in general?

# if task is given, make sure the file exists

if ($task && !(-f "$task.task")) {die("$task: no such task in $dir");}

debug("ACTION: $action, TASK: $task");

# TODO: consider nicer version of die
# TODO: subroutinize

if ($action=~/^(start|begin)$/i) {

  # have I already started?
  if (-f "$task.task.new") {die("$task: task already started");}

  # OK, cp to .new and tell user
  ($out, $err, $res) = cache_command2("cp $task.task $task.task.new");
  
  if ($res) {die("$task: CP FAILED FOR SOME REASON");}

  print "$task: Task started\n";

  exit(0);
}

# stop = not finishing a task (TODO: better verbiage here)

if ($action=~/^(stop|fail)$/i) {

  # have I already started?
  unless (-f "$task.task.new") {die("$task: task not started");}

  # OK, rm .new and tell user
  ($out, $err, $res) = cache_command2("rm $task.task.new");
  
  if ($res) {die("$task: CP FAILED FOR SOME REASON");}

  print "$task: Task stopped, not completed\n";

  exit(0);
}

if ($action=~/^(end|finish)$/i) {

  # can't stop what you haven't started
  # TODO: HOWEVER, do want to allow start/finish at same time
  unless (-f "$task.task.new") {die("$task: task not started");}

  # OK, resolve task and tell user
  ($out, $err, $res) = cache_command2("mv $task.task $task.task.old && mv $task.task.new $task.task");
  
  if ($res) {die("$task: MV FAILED FOR SOME REASON");}

  print "$task: Task completed\n";

  exit(0);
}

if ($action=~/^list$/i) {

  ($out, $err, $res) = cache_command2("find . -iname '*.task' -printf \'%T\@ %f\n\' | sort -n");

  for $i (split(/\n/, $out)) {

    my($time, $task) = split(/\s+/, $i);

    $time = strftime("%Y%m%d.%H%M%S", localtime($time));
    my($data) = read_file($task);
    chomp($data);
    $task=~s/\.task//;

    # TODO: list in progress on top or something?
    my($inprog) = (-f "$task.task.new")?" (IN PROGRESS) ":"";

    print "$time \e[1m$task$inprog\e[0m $data\n";

  }

  exit(0);

}

die("$action: not understood");

