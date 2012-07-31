#!/bin/perl

# a trivial redirector for use on 94y.info

if ($ENV{HTTP_HOST} eq "tutor.u.94y.info") {
  # my permanent(?) scribblar board
  print "Location: http://www.scribblar.com/wwcdp0qj";

  # twiddla.com = no flash!
#  print "Location: http://www.twiddla.com/897838";

}

print "\n\n";



