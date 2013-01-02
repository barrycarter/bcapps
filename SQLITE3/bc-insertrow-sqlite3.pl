#!/usr/bin/perl -0777
# above: slurp the entire stdin

require "/usr/local/lib/bclib.pl";

print "Content-type: text/html\n\n";

$tabname = "foods";
$db = "/home/barrycarter/BCINFO/sites/DB/myfoods.db";

# this is terrible, dont do it
my(@res) = hashlist2sqlite([{str2hash(<STDIN>)}], $tabname);

# this is also terrible
open(A,"|sqlite3 $db 1> /tmp/bcirs.out 2> /tmp/bcirs.err");
print A "BEGIN;\n";
for $i (@res) {
  print A "$i;\n";
  # just for debugging
  print "$i<br>\n";
}
print A "COMMIT;\n";
close(A);

print "Maybe worked...\n";

