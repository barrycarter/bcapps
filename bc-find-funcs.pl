#!/bin/perl

# compares defined functions to called functions, with reference to my
# coding style

require "/usr/local/lib/bclib.pl";

# read the given file
# TODO: allow mutliple files (or is that bad?)
my($file) = @ARGV;
$data = read_file($file);

# perl "constructs" that use ()
%defined = list2hash("if", "for", "while", "elsif", "unless");

# requires (by filename; requires by package handled differently)
do {
  $data=~s/require\s*\"(.*?)\"//;
  my($req) = $1;
  $data = "$data\n".read_file($req);
} until ($data!~/require\s*\"(.*?)\"/);

debug("DATE: $data");

# kill comments
$data=~s/\#.*$//mg;

# kill perldoc
while ($data=~s/(^|\n)\=item(.*?)\=cut//is) {debug("CUT: $2");}

# defined functions
while ($data=~s/sub\s*(\w+?)\s*\{//s) {
  $defined{$1} = 1;
}

# imported functions
while ($data=~s/use [^\n]+?\s+qw\((.*?)\)//m) {
  my($funcs) = $1;
  for $i (split(/\s+/,$funcs)) {$defined{$i}=1;}
}

# implicit imports (no specific import) and explicit perlfunc
$uses{perlfunc} = 1;
while ($data=~s/^use (.*?)\;//m) {$uses{$1}=1;}

# now, use perldoc to figure out what commands they give me
# NOTE: this assumes everything is exported which is wrong
for $i (keys %uses) {
  debug("I: $i");
  my($out,$err,$res) = cache_command("perldoc -u $i | egrep =item","age=86400");
  for $j (split(/\n/,$out)) {
    debug("J: $j");
    unless ($j=~s/\=item\s+(\w*)//) {next;}
    $defined{$1} = 1;
  }
}

# called functions
while ($data=~s/(\w+?)\([^\(\)]*?\)//s) {
  # this catches funcs and more
  my($func) = $1;
  debug("FUNC: $func");
  # funcs must start with letter and contain only alpha chars
  # I assume using foo::bar::func() means you know what you're doing
  # below allows for "=item func(thing)"
  unless ($func=~/^[a-z]\w+$/i) {next;}
  $used{$func} = 1;
}

@defined = sort (keys %defined);
@used = sort (keys %used);

@missing = sort(minus(\@used, \@defined));

print join("\n",@missing),"\n";





