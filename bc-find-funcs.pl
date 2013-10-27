#!/bin/perl

# compares defined functions to called functions, with reference to my
# coding style

require "/usr/local/lib/bclib.pl";

# read the given file
# TODO: allow mutliple files (or is that bad?)
my($file) = @ARGV;
$data = read_file($file);

# requires (by filename; requires by package handled differently)
# TODO: include recursive requires
do {
  $data=~s/require\s*\"(.*?)\"//;
  my($req) = $1;
  $data = "$data\n".read_file($req);
} until ($data!~/require\s*\"(.*?)\"/);

# kill comments
$data=~s/\#[^\n]*\n//isg;

# defined functions
while ($data=~s/sub (\w+) \{//) {
  push(@defined, $1);
}






debug("DATA: $data");

die "TESTING";

while ($data=~s/(\S+?)\(.*?\)//s) {
  # this catches funcs and more
  my($func) = $1;
  # funcs must start with letter and contain only alpha chars
  unless ($func=~/^[a-z]\w*$/i) {next;}

  debug($func);
}

