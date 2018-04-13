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

  unless ($i=~m%/([^\/]+)/([^\-\/]+)\-([\dTZ\.]+)\.zip$%) {next;}
  my($site, $acct, $date) = ($1, $2, $3);

  # ignore "dates" that come from files like where
  # Complete_LinkedInDataExport_03-08-2018.zip yields a "date" of 2018
#  if (length($date) < 8) {next;}

  debug("$site,$acct,$date from:", $i);
}

# TODO: remember to look at ~/myaccounts.txt for accounts that have
# perhaps never been backedup

=item comment

Sample file names AFTER I run bc-*-zip.pl:

LINKEDIN/linkedin@barrycarter.info-20180308.083352.zip 

TWITTER/barrycarter-20180225.151142.zip

FACEBOOK/barry.carter.121-20180127.080552.zip

GOOGLE/carter.barry@gmail.com-20180401T181753Z.zip

=cut
