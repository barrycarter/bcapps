#!/bin/perl

# converts nutrisystem foods (from spreadsheet) to myfoods.db, but
# only ones where I've noted a UPC (the data that comes from
# nutrisystem does not include a UPC)

require "/usr/local/lib/bclib.pl";

gnumeric2sqlite3("/home/barrycarter/BCGIT/FOODTRACK/nutrisystem.gnumeric", "foods", "/tmp/myfoods.db");

my(@coln) = sqlite3cols("foods", "/tmp/myfoods.db");
my(@colo) = sqlite3cols("foods", "/home/barrycarter/BCINFO/sites/DB/myfoods.db");

@need = minus(\@coln, \@colo);

debug("DIFF",@need);
