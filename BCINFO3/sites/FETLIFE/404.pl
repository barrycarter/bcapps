#!/usr/local/bin/perl

# Handles 404 errors on fetlife site including things like:
# http://fetlife.94y.info/countries/97/kinksters?page=3
# which should really be:
# http://fetlife.94y.info/countries/97/kinksters%3fpage%3d3

require "/usr/local/lib/bclib.pl";

# special case if requesting a user

if ($ENV{REQUEST_URI}=~m%^/users/(\d+)$%) {
  system("/usr/local/bin/fl-psuedo-profile.pl $1");
  exit;
}

my($file) = "/sites/FETLIFE/$ENV{REQUEST_URI}";

if (-f $file) {print "Content-type: text/html\n\n",read_file($file);exit;}

if (-f "$file.bz2") {
  print "Content-type: text/html\n\n";
  print `bzcat $file.bz2`;
  exit;
}

print "Location: https://fetlife.com/$ENV{REQUEST_URI}\n\n";


