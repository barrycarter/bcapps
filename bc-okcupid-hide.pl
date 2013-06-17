#!/bin/perl

# Hides okcupid people I've already sent email to
# To use this program:
#   - Go to Sent mail tab (not Received!)
#   - Save as /home/barrycarter/Download/messages.html (the default)
#   - run this program
#   - repeat last 3 steps for each page on Sent mail
#   - download and run the GreaseMonkey script it creates

require "/usr/local/lib/bclib.pl";

$scriptfile = "/home/barrycarter/20130616/okcupid-mark.user.js";

$all = read_file("/home/barrycarter/Download/messages.html");
while ($all=~s/Mailbox\.deleteQueue\('\d+','(.*?)'\)//) {$user{$1}=1;}
open(A,">$scriptfile.new");

print A << "MARK";
// \@name okcupid-mark
// \@namespace http://barrycarter.info
// \@description Marks OkCupid users I have already contacted
// \@include *okcupid*
// ==/UserScript==
MARK
;

for $i (sort keys %user) {
  push(@str,"str.replace(/$i/gi,'XXX-$i-XXX')");
}

print A join("\n",@str),"\n";
close(A);

# merge in old stuff
system("fgrep str.replace $scriptfile >> $scriptfile.new");

# sort out repeats
system("sort  $scriptfile.new -u -o  $scriptfile.new");

# replace
system("mv $scriptfile $scriptfile.old; mv $scriptfile.new $scriptfile");

# and visit
system("/root/build/firefox/firefox -remote 'openURL(file:///$scriptfile)'");
