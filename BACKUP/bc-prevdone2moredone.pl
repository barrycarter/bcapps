#!/bin/perl

# given a list of files that have already been backed up, pretend
# those files have also been backed up in other locations (eg, if a
# file is moved from one directory to another)

require "/usr/local/lib/bclib.pl";

# read list of conversions in format: '"X" "Y"' where X (in quotes) is
# where the file was originally backed up and Y (in quotes) is where
# we pretend the file was also backedup; multiple Y's are allowed for
# one X

# the initial prevdone-conversions.txt files are bc-conversions.txt in
# reverse order

my(@converts) = `egrep -hv '^ *\$|^#' $bclib{githome}/BACKUP/prevdone-conversions.txt $bclib{home}/BCPRIV/prevdone-conversions-private.txt`;

debug(@converts);

# TODO: use egrep to do this efficiently perhaps (but try going through all first?)

