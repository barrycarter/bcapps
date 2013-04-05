#!/bin/perl

# a trivial redirector for use on 94y.info
# r.u.94y.info is to catch scammers IP addresses
use MIME::Base64;

# catchall redirection for my link tracker
if ($ENV{HTTP_HOST} eq "u.94y.info") {
  # remove leading / and ?
  $ENV{REQUEST_URI}=~s/\/\?//;
  # convert to true URL
  $ENV{REQUEST_URI} = decode_base64($ENV{REQUEST_URI});
  print "Location: $ENV{REQUEST_URI}\n";
} elsif ($ENV{HTTP_HOST} eq "tutor.u.94y.info") {
  # my permanent(?) scribblar board
  print "Location: http://wordpress.barrycarter.info/index.php/free-math-tutoring-at-httpwww-scribblar-comwwcdp0qj/";

  # twiddla.com = no flash!
  #  print "Location: http://www.twiddla.com/897838";
} elsif ($ENV{HTTP_HOST} eq "r.u.94y.info") {
  print "Location: http://www.yahoo.com/";
} elsif ($ENV{HTTP_HOST} eq "s.u.94y.info") {
  print "Location: https://github.com/barrycarter/bcapps/blob/master/bc-starmap.pl";
} elsif ($ENV{HTTP_HOST} eq "419s.u.94y.info") {
  print "Location: http://wordpress.barrycarter.info/index.php/2013/03/01/why-419eater-com-sucks/";
} else {
  # do nothing
}

print "\n\n";
