#!/bin/perl

# potentially better way of parsing stuff (ultimately for referata.com)

require "/usr/local/lib/bclib.pl";

dodie('chdir("/home/barrycarter/BCGIT/METAWIKI")');
my(@data) = `/bin/cat pbs.txt pbs-cl.txt`;

# character class excluding right bracket
$cc = "[^\\[\\]]";

for $i (@data) {
  debug("I: $i");
 
  # the [[x::y::z]]
  while ($i=~s/\[\[($cc*?)::($cc*?)::($cc*?)\]\]/$3/) {$data{$1}{$2}{$3}=1;}



}
