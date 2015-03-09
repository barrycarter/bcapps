#!/bin/perl

# Fun w/ FUSE

require "/usr/local/lib/bclib.pl";
use Fuse::Simple qw(accessor main);

# TODO: this is bad
$zpaq = "/root/build/ZPAQ71/zpaq";

# hardcoded for now
my($zfile) = "/home/barrycarter/20150308/testfile.zpaq";

chdir("/var/tmp/fuse/");
# just for testing
system("rm -rf /var/tmp/fuse/*");

# list of files
my($out,$err,$res) = cache_command("$zpaq list $zfile", "age=86400");

# TODO: error checking

my($fs);
my(%meta);

for $i (split(/\n/, $out)) {

  my($symb, $date, $time, $size, $mode, $file) = split(/\s+/,$i,6);
  # ignore directories and non-file entries
  unless ($symb eq "-") {next;}
  # record file metadata (even for dirs, stripping trailing slash(es))
  # however, leave root directory as is
  $file=~s%/+$%%;
  $meta{"/$file"} = $i;
#  debug("META(/$file): $i");
  if ($mode=~/^d/) {next;}

#  $file="/$file";
  my(@dirs) = split(/\//, $file);
  map($_="{'$_'}", @dirs);

  # TODO: there must be a better way to do this (tm)
  my($eval) = "\$fs->".join("",@dirs)."=sub{read_zpaq_file('$file','$zfile')}";
  eval($eval);

}

# TODO: turn on threading when possible
main("mountpoint" => "/home/barrycarter/20150308/fusetest", "/" => $fs,
    "threaded" => 0);

# TODO: create cronjob or something to delete unused files
sub read_zpaq_file {
  my($file,$zfile) = @_;
  # create file if it doesn't exist
  unless (-f $file) {system("$zpaq extract $zfile $file 1> /dev/null");}
  return read_file($file);
}

sub Fuse::Simple::fs_getattr {
  my($file) = @_;
  debug("META($file): $meta{$file}");

  # if there is no metadata, pretend its a directory with 0 time (this
  # will happen for "/" for example)
  my($symb, $date, $time, $size, $mode) = split(/\s+/,$meta{$file},5);

  unless ($symb eq "-") {return 4242,1,16749,1,0,0,1,0,0,0,0,0,0;}

  my($mtime) = str2time("$date $time");
  # determine mode
  if ($mode=~/^d/) {$mode=16749;} else {$mode=33133;};
  debug("MTIME: $mtime");

  # ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size, $atime,$mtime,$ctime,$blksize,$blocks) = getattr($filename);

  # TODO: handle symlinks properly?
  # TODO: return better mode, currently -r-x-r-x-r-x for all
  # 33133 = mode above for files, 16749 = for dirs
  # currently (testing): rdev=1, size=2, etc
  debug("RETURNING", 4242,1,$mode,1,0,0,1,$size,0,$mtime,0,0,0);
  return 4242,1,$mode,1,0,0,1,$size,0,$mtime,0,0,0;
}
