#!/usr/local/bin/perl

# Handles 404 errors on fetlife site including things like:
# http://fetlife.94y.info/countries/97/kinksters?page=3
# which should really be:
# http://fetlife.94y.info/countries/97/kinksters%3fpage%3d3

require "/usr/local/lib/bclib.pl";
print "Content-type: text/plain\n\n";

for $i (sort keys %ENV) {
 print "$i => $ENV{$i}\n";
}

my($file) = "/sites/FETLIFE/$ENV{REQUEST_URI}";

if (-f $file) {print read_file($file);}

print "hmmmm";

