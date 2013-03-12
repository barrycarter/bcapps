#!/bin/perl

# uses imacro to add to list of scammers without hitting fiesta.cc
# "large list limit"

require "/usr/local/lib/bclib.pl";

die "DO NOT USE; confirmed.txt format has changed";

@addr = split(/\n/,`egrep -v '^#|^\$' /home/barrycarter/BCGIT/419/confirmed.txt`);

for $i (@addr) {
print << "MARK";
TAG POS=1 TYPE=INPUT:TEXT FORM=ACTION:/add ATTR=ID:add-field CONTENT=$i
TAG POS=1 TYPE=INPUT:SUBMIT FORM=ID:add ATTR=VALUE:Add<SP>to<SP>list
MARK
;
}

