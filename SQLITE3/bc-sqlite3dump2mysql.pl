#!/bin/perl

# this only converts INSERTS, not schema (since sqlite3 schema is
# often incompatible with mysql schema anyway)
# converts an sqlite3 dump to a MySQL style dump (trivial)
# indexes on text columns will not convert over
# typeless columns will also require editing

print "BEGIN;\n";
while (<>) {
  # TODO: all apostrophes are bad?
  s/\'//isg;
  if (s/INSERT OR REPLACE/REPLACE/) {print $_;}
}
print "COMMIT;\n";
