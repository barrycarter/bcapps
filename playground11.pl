#!/bin/perl

# Fun w/ FUSE

require "/usr/local/lib/bclib.pl";
use Fuse::Simple qw(accessor main);

# list of files in (currently hardcoded) zpaq file
my($out,$err,$res) = cache_command("/root/build/ZPAQ71/zpaq list /home/barrycarter/20150308/testfile.zpaq", "age=86400");

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
  debug("EVAL: $eval");
  eval($eval);

  if ($count++>100) {last;}


  # TODO: there must be a better way to do this (tm)
#  $file=~s%/%\}\{%g;
#  $file="\$fs->\{$file\} = sub {test(\"$file\")};";

#  debug("F: $file");

#  $fs->{$file} = sub {test($file);};
}

debug("FS",unfold($fs));

sub test {return $_[0];}

main("mountpoint" => "/home/barrycarter/20150308/fusetest", "/" => $fs);

