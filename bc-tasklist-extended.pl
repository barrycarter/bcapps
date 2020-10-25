#!/bin/perl

# A trivial "task list" that looks at a directory and lists files
# (matching *.task) oldest to newest (oldest = task that hasn't been
# done for longest) and lets me mark when I'm working on a task and
# when I've finished

# extended version finds task that is furthest behind based on how
# often they are supposed to run, and can also auto run tasks (for
# nagyerass)

# Usage: $0 (list|start/begin|stop/fail|end/finish) [task]

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

# append to task log
open(A, ">> $task.log");
my($now) = time();

# TODO: consider nicer version of die
# TODO: subroutinize

if ($action=~/^(start|begin)$/i) {

  # have I already started?
  if (-f "$task.task.new") {die("$task: task already started");}

  # OK, cp to .new and tell user
  ($out, $err, $res) = cache_command2("cp $task.task $task.task.new");
  
  if ($res) {die("$task: CP FAILED FOR SOME REASON");}

  print "$task: Task started\n";

  print A "$now $task START\n";

  exit(0);
}

# stop = not finishing a task (TODO: better verbiage here)

if ($action=~/^(stop|fail|abort)$/i) {

  # have I already started?
  unless (-f "$task.task.new") {die("$task: task not started");}

  # OK, rm .new and tell user
  ($out, $err, $res) = cache_command2("rm $task.task.new");
  
  if ($res) {die("$task: CP FAILED FOR SOME REASON");}

  print "$task: Task stopped, not completed\n";

  print A "$now $task STOP\n";

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

  print A "$now $task END\n";

  exit(0);
}

my(%timestamps);

if ($action=~/^list$/i) {

  # TODO: this could theoretically break if there were enough tasks

  my(@files) = glob("*.task");

  for $i (@files) {
    debug($i, find_last_run($i));
  }

  die "TESTING";

  ($out, $err, $res) = cache_command2("find . -maxdepth 1 -iname '*.task' -printf \'%T\@ %f\n\'");

  # first we get the timestamps

  for $i (split(/\n/, $out)) {

    my($time, $task) = split(/\s+/, $i);

    # just the task name
    $task=~s/\.task//;

    # assign timestamp as mtime and maybe change it later
    $timestamps{$task} = $time;

    # but if there's something in the log file, use that instead

    ($out, $err, $res) = cache_command2("tac $task.log | grep -m 1 END");
    if ($out) {$timestamps{$task} = [split(/\s+/, $out)]->[0];}

    debug("TIMESTAMP($task) = $timestamps{$task}");

  }

  # now to print them in timstamp order

  for $i (sort {$timestamps{$a} <=> $timestamps{$b}} keys %timestamps) {

    my($task, $time) = ($i, $timestamps{$i});

#    debug("OUT: $out");

    debug("TIME: $time, TASK: $task");

    $time = strftime("%Y%m%d.%H%M%S", localtime($time));

    debug("TIME NOW: $time");

    my($data) = read_file("$task.task");
    chomp($data);

    # TODO: list in progress on top or something?
    my($inprog) = (-f "$task.task.new")?" (IN PROGRESS) ":"";

    print "$time \e[1m$task$inprog\e[0m $data\n";

  }

  exit(0);

}

die("$action: not understood");

# specific to this program only, find last run time of task, using log
# file if available, mtime if not

sub find_last_run {

  my($task) = @_;

  # if $task happens to end in .task remove the .task

  $task=~s/\.task$//s;

  # if the task file doesn't exist, return -1

  unless (-f "$task.task") {
    warn "NO TASK FILE: $task";
    return -1;
  }

  # use log file (if it doesnt exist, this still does the right thing)

  my($out, $err, $res) = cache_command2("tac $task.log | grep -m 1 END");

  if ($out) {return [split(/\s+/, $out)]->[0];}

  # if no log file, use mtime

  my($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)=stat("$task.task");

  return $mtime;
}





