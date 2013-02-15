#!/bin/perl

# converts nutrisystem foods (from spreadsheet) to myfoods.db, but
# only ones where I've noted a UPC (the data that comes from
# nutrisystem does not include a UPC)

require "/usr/local/lib/bclib.pl";

gnumeric2sqlite3("/home/barrycarter/BCGIT/FOODTRACK/nutrisystem.gnumeric", "foods", "/tmp/myfoods.db");

# you would think sqlite3hashlist and hashlist2sqlite do the opposite
# of each other, but not really, because, together they can fix broken
# column order
@res = sqlite3hashlist("SELECT * FROM foods WHERE UPC", "/tmp/myfoods.db");
@querys = hashlist2sqlite(\@res, "foods");

for $i (@querys) {print "$i;\n";}

exit();



my(@coln) = sqlite3cols("foods", "/tmp/myfoods.db");
my(@colo) = sqlite3cols("foods", "/home/barrycarter/BCINFO/sites/DB/myfoods.db");

@need = minus(\@coln, \@colo);

debug("DIFF",@need);
