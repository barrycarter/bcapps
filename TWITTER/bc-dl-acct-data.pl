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

# hash to keep latest save for each account
my(%latest);

# list of all my accounts; set time to "0" here just in case they've
# never been backed up (actually setting to "1" because stardate()
# treats 0 as "now"

($out, $err, $res) = cache_command2("egrep -v '^#' $bclib{home}/myaccounts.txt");

for $i (split(/\n/, $out)) {
  unless ($i=~m%^(.*?):(\S+)%) {warn "BAD LINE: $i"; next;}
  $latest{lc("$1:$2")} = 1;
}

# TODO: dont cache in production?
# NOTE: bc-*-zip.pl creates symlinks, thus "-type l"
# however, can also be files, so -o
# TODO: try to add -iname '*.zip' to this w/o breaking OR condition

($out, $err, $res) = cache_command2("find $dirspec -type l -o -type f", "age=3600");

for $i (split(/\n/, $out)) {

  
#  unless ($i=~m%/([^\/]+)/([^\-\/]+)\-([\dTZ\.]+)\.zip$%) {next;}

  # alt form allows notes or whatever after date
  unless ($i=~m%/([^\/]+)/([^\-\/]+)\-([\dTZ\.]+).*?\.zip$%) {next;}
  my($site, $acct, $date) = (lc($1), lc($2), $3);

  # convert "stardate" to form that makes str2time happy
  $date=~s/(\d{4})(\d{2})(\d{2})\.(\d{2})(\d{2})(\d{2})/$1-$2-$3 $4:$5:$6/;

  debug("DATE: $date");
  $date = str2time($date);

  debug("$site/$acct/$date");
  $latest{"$site:$acct"} = max($latest{"$site:$acct"}, $date);
}

for $i (sort {$latest{$b} <=> $latest{$a}} keys %latest) {
  print stardate($latest{$i})," $i\n";
}

# debug(var_dump("latest",\%latest));

# TODO: remember to look at ~/myaccounts.txt for accounts that have
# perhaps never been backedup

=item comment

Sample file names AFTER I run bc-*-zip.pl:

LINKEDIN/linkedin@barrycarter.info-20180308.083352.zip 

TWITTER/barrycarter-20180225.151142.zip

FACEBOOK/barry.carter.121-20180127.080552.zip

GOOGLE/carter.barry@gmail.com-20180401T181753Z.zip

=cut
