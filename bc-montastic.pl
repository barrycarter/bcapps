#!/bin/perl

# figure out which services are down (using montastic API + multiple
# accounts) and "report" these to ~/ERR which ultimately prints to my
# background image

# TODO: if result file is empty or doesnt have any status, that's an error

# -nocurl: dont actually query montastic API (useful for testing)

require "/usr/local/lib/bclib.pl";

dodie('chdir("/var/tmp/montastic")');

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
