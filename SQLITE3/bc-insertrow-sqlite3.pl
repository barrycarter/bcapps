#!/usr/bin/perl -0777
# above: slurp the entire stdin

require "/usr/local/lib/bclib.pl";

print "Content-type: text/html\n\n";

$globopts{keeptemp} = 1;
$tabname = "foods";
$db = "/home/barrycarter/BCINFO/sites/DB/myfoods.db";

# convert + to ' ' (using spaces in my SQLite3 col names was a bad idea)
my($stdin) = <STDIN>;
$stdin=~s/\+/ /isg;

# this is terrible, dont do it
my(@res) = hashlist2sqlite([{str2hash($stdin)}], $tabname);

# run SQLite3 query
chdir(tmpdir("bcirs"));
open(A,"> queries.txt");
print A "BEGIN;\n";
for $i (@res) {
  print A "$i;\n";
  # just for debugging
  print "$i<br>\n";
}
print A "COMMIT;\n";
close(A);

system("sqlite3 $db < queries.txt 1> /tmp/bcirs.out 2> /tmp/bcirs.err");

print "Maybe worked...\n";

