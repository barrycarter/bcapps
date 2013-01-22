#!/bin/perl

# a trivial redirector for use on 94y.info
# r.u.94y.info is to catch scammers IP addresses

if ($ENV{HTTP_HOST} eq "tutor.u.94y.info") {
  # my permanent(?) scribblar board
  print "Location: http://wordpress.barrycarter.info/index.php/free-math-tutoring-at-httpwww-scribblar-comwwcdp0qj/";

  # twiddla.com = no flash!
#  print "Location: http://www.twiddla.com/897838";

} elsif ($ENV{HTTP_HOST} eq "r.u.94y.info") {
  print "Location: http://www.yahoo.com/";
} elsif ($ENV{HTTP_HOST} eq "s.u.94y.info") {
  print "Location: https://github.com/barrycarter/bcapps/blob/master/bc-starmap.pl";
} else {
  # do nothing
}

print "\n\n";



