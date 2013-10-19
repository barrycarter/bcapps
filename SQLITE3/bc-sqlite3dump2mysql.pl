#!/bin/perl

# this only converts INSERTS, not schema (since sqlite3 schema is
# often incompatible with mysql schema anyway)
# converts an sqlite3 dump to a MySQL style dump (trivial)
# indexes on text columns will not convert over
# typeless columns will also require editing

while (<>) {if (s/INSERT INTO \"(.*?)\"/INSERT INTO $1/) {print $_;}}


