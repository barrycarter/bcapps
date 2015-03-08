#!/bin/perl

# Fun w/ FUSE

require "/usr/local/lib/bclib.pl";
use Fuse::Simple qw(accessor main);

# list of files in (currently hardcoded) zpaq file
my($out,$err,$res) = cache_command("/root/build/ZPAQ71/zpaq list /home/barrycarter/20150308/testfile.zpaq", "age=86400");

# TODO: error checking

my(%fs);

for $i (split(/\n/, $out)) {
  my($symb, $date, $time, $size, $mode, $file) = split(/\s+/,$i,6);
  # ignore directories and non-file entries
  unless ($symb eq "-") {next;}
  if ($mode=~/^d/) {next;}

  # TODO: there must be a better way to do this (tm)
#  $file=~s%/%\}\{%g;
#  $file="\$fs->\{$file\} = sub {test(\"$file\")};";

  $fs->{$file} = sub {test($file);};
}

debug("OUT: $out");

$var = "x";
$fs->{foo}{bar}{$var} = sub {test($var)};
$fs->{foo}{bar}{y} = sub {test("y")};

sub test {return $_[0];}

die "TESTING";


main("mountpoint" => "/home/barrycarter/20150308/fusetest", "/" => $fs);







  my $var = "this is a variable you can modify. write to me!\n";
  my $filesystem = {
    foo => "this is the contents of a file called foo\n",
    subdir => {
      "foo"  => "this foo is in a subdir called subdir\n",
      "blah" => "this blah is in a subdir called subdir\n",
    },
    "blah" => \ "subdir/blah",        # scalar refs are symlinks
    "magic" => sub { return "42\n" }, # will be called to get value
    "var"  => accessor(\$var),        # read and write this variable
    "var2" => accessor(\$var),        # and the same variable
    "var.b" => accessor(\ my $tmp),   # and an anonymous var
    "date" => sub {return time();}
  };

  main(
    "mountpoint" => "/home/barrycarter/20150308/fusetest",      # actually optional
    "debug"      => 0,           # for debugging Fuse::Simple. optional
    "fuse_debug" => 0,           # for debugging FUSE itself. optional
    "threaded"   => 0,           # optional
    "/"          => $filesystem, # required :-)
  );
