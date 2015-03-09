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

for $i (split(/\n/, $out)) {

  my($symb, $date, $time, $size, $mode, $file) = split(/\s+/,$i,6);
  # ignore directories and non-file entries
  unless ($symb eq "-") {next;}
  if ($mode=~/^d/) {next;}

#  $file="/$file";
  my(@dirs) = split(/\//, $file);
  map($_="{'$_'}", @dirs);

  my($eval) = "\$fs->".join("",@dirs)."=sub{test('$file')}";
  eval($eval);

  # TODO: there must be a better way to do this (tm)
}

sub test {
  my($file) = @_;
  # create file if it doesn't exist
  unless (-f $file) {system("$zpaq extract $zfile $file 1> /dev/null");}
  return read_file($file);
}

main("mountpoint" => "/home/barrycarter/20150308/fusetest", "/" => $fs,
    "threaded" => 1);

sub Fuse::Simple::fs_getattr {
  my($file) = @_;
  return 0,1,16893,3,4,5,6,7,8,9,10,11,12;
}
