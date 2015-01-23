#!/bin/perl

# mirrors a local directory a server root even more efficiently than
# rsync by remembering time of previous mirror
# --dryrun = don't actually do anything, use rsync -n

# TODO: assumes mirroring as root@ (VPS), which may be bad

require "/usr/local/lib/bclib.pl";

my($dir,$server) = @ARGV;

unless ($dir=~m%^\/%) {die "dir must be full path, not $dir";}
unless ($server) {die "Usage: $0 directory server";}
# strip trailing slashes
$dir=~s%/+$%%g;
# and chdir to it
dodie("chdir('$dir')");

# the lastmirror file depends on both $dir and $server so you can
# mirror the same directory to different servers out of sync

my($mirfile) = "/usr/local/etc/bcmirror/$dir/lastmirror.$server";

# TODO: check to see if user really needs to "mkdir" or not
unless (-f $mirfile) {
  # dont do this for user, since they may just have wrong directory
  die("No lastmirror file, try touch -t 7001010000 $mirfile (you may need to 'mkdir -p' first)");
}

# before we mirror anything, touch new timestamp (so we'll catch files
# that change during the mirror)
system("touch $mirfile.new");

# find all files newer than last mirror in source directory
# TODO: USE HOSTNAME!
@files = `find . -follow -type f -newer $mirfile`;

# skip unwanted files
for $i (@files) {
  chomp($i);
  if ($i=~/\~$/) {debug("$i SKIPPED/EMACS"); next;}
  if ($i=~/\.git/) {debug("$i SKIPPED/GIT"); next;}
  # relativize path
  $i=~s/^$dir//;
  push(@mirror,$i);
}

# no changes at all?
if ($#mirror==-1) {die("No files have changed");}

# write files to mirror
write_file(join("\n",@mirror)."\n","$mirfile.todo");

# set flags
# TODO: add options for verbosity
if ($globopts{dryrun}) {$opts = "-n";}

my($com)="rsync -vv -P $opts -z -R -L --files-from=$mirfile.todo . root\@$server:/";

debug($com);
my($out,$err,$res) = cache_command2($com);
debug("OUT: $out, ERR: $err, RES: $res");

if ($res) {die "Command returned $res: $com";}

# assumed success here (unless dry run)
unless ($globopts{dryrun}) {
  system("mv $mirfile $mirfile.old; mv $mirfile.new $mirfile");
}
