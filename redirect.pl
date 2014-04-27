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
} elsif ($ENV{HTTP_HOST} eq "e.u.94y.info") {
  # redirect to echo server (listening on port 8080)
  print "Location: http://wordpress.barrycarter.info:8080\n";
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
} elsif ($ENV{HTTP_HOST} eq "ftf.u.94y.info") {
  print "Location: http://wordpress.barrycarter.info/index.php/free-open-source-perl-script-to-increase-twitter-followers/";
} elsif ($ENV{HTTP_HOST} eq "lt.u.94y.info") {
  print "Location: http://wordpress.barrycarter.info/index.php/track-albuquerque-lightning-july-16th-20th/";
} elsif ($ENV{HTTP_HOST} eq "pbs.u.94y.info") {
  print "Location: http://wordpress.barrycarter.info/index.php/2014/04/23/pearls-before-swine-comments";
} else {
  # do nothing
}

print "\n\n";
