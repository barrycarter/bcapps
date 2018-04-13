#!/bin/perl

# Determines which social media (facebook/twitter/google/linkedin)
# account I haven't downloaded for the longest time so I can keep
# downloads in rotation

# TODO: does NOT include creditkarma, creditsesame, nextdoor, tumblr,
# stackexchange, or others

require "/usr/local/lib/bclib.pl";

my($out, $err, $res);

# find all files in dirs where I backup stuff
# TODO: this is serious overkill, most aren't even backups

my(@dirs) = ("LINKEDIN", "TWITTER", "FACEBOOK", "GOOGLE");

my($dirspec) = join(" ",map($_ = "$bclib{home}/$_", @dirs));

# TODO: dont cache in production?
($out, $err, $res) = cache_command2("find $dirspec -type f", "age=3600");

for $i (split(/\n/, $out)) {

  # TODO: testing for three regexs here (twitter/facebook share) ugly

  my($date);

  if ($i=~m/(\d{8}\.\d{6})\.zip/) {$date = $1;}
  elsif ($i=~m/Complete_LinkedInDataExport_(\d{2}\-\d{2}\-\d{4})\.zip/) {$date=$1;}
  elsif ($i=~m/takeout\-(\d{8}T\d{6}Z)/) {$date = $1;}
  else {next;}

  debug("I: $i, date is: $date");
}

# TODO: remember to look at ~/myaccounts.txt for accounts that have
# perhaps never been backedup

=item comment

Sample file names:

LINKEDIN/Complete_LinkedInDataExport_03-08-2018.zip

TWITTER/barrycarter-20180130.223052.zip

FACEBOOK/barry.carter.121-20180127.080552.zip

GOOGLE/takeout-20180320T144223Z-001.zip

=cut
