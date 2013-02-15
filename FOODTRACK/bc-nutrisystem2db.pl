#!/bin/perl

# converts nutrisystem foods (from spreadsheet) to myfoods.db, but
# only ones where I've noted a UPC (the data that comes from
# nutrisystem does not include a UPC)

require "/usr/local/lib/bclib.pl";

gnumeric2sqlite3("/home/barrycarter/BCGIT/FOODTRACK/nutrisystem.gnumeric", "myfoods", "/tmp/myfoods.db");

