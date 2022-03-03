#!/bin/perl

# given a URL on the command line that's an RSS feed of
# uptimerobot.com, do pretty much what bc-montastic.pl does

# TODO: if result file is empty or doesnt have any status, that's an error

# -nocurl: dont actually query montastic API (useful for testing)

require "/usr/local/lib/bclib.pl";

dodie('chdir("/var/tmp/uptimerobot")');

unless ($#ARGV == 0) {die("Usage: $0 url");}

# TODO: caching is really only for testing

my($out, $err, $res) = cache_command("curl -L $ARGV[0] | tee feed.txt", "age=3600");

debug("OUT: $out");

# go through each item in the RSS feed

# TODO: make sure results are recent

my(%status);

while ($out=~s%<item>(.*?)</item>%%s) {

  my($data) = $1;

  my(%hash) = ();

  while ($data=~s%<(.*?)>(.*?)</\1>%%s) {$hash{$1} = $2;}

  unless ($hash{title}=~s%(.*?) is (UP|DOWN)%%) {
    push(@errors, "Test neither up nor down");
    next;
  }

  my($test, $status) = ($1, $2);

  # if I already have a status, ignore this one, newest at top

  if ($status{$test}) {next;}

  # otherwise set status and report error if down


}

die "TESTING";

# format of this file, each line is "username:password", # starts comments
for $i (split(/\n/,read_file("$ENV{HOME}/montastic.txt"))) {
  if ($i=~/^\#/ || $i=~/^\s*$/) {next;}
  ($user,$pass) = split(":",$i);
  push(@cmds, "curl -s -H 'Accept: application/xml' -u $user:$pass https://www.montastic.com/checkpoints/index > output-$user.new; mv -f output-$user output-$user.old; mv -f output-$user.new output-$user");
  push(@files, "output-$user");
}

write_file(join("\n",@cmds)."\n", "commands.txt");

unless ($globopts{nocurl}) {system("parallel -j 20 < commands.txt");}

for $j (@files) {
  # look at results
  $all = read_file($j);

  while ($all=~s%<checkpoint>(.*?)</checkpoint>%%is) {
    $res = $1;

    # ignore turned off monitors
    if ($res=~m%<is-monitoring-enabled type="boolean">false</is-monitoring-enabled>%) {next;}

    # ignore good results
    if ($res=~m%<status type="integer">1</status>%) {next;}

    # offending URL
    $res=~m%<url>(.*?)</url>%isg;
    my($url) = $1;

    # error!
    $user = $j;
    $user=~s/^output\-//;
    push(@errors, "$url [$user]");
  }
}

write_file_new(join("\n",@errors)."\n", "/home/barrycarter/ERR/montastic.err");
