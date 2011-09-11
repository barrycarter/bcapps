#!/bin/perl

print "Content-type: text/plain\n\n";
$|=1;

for (;;) {
  print time()."\n";
  sleep(1);
}
