#!/bin/perl

# trivial wrapper around recent_forecast() to populate db
# this is run via cron since guidance is infrequently updated

require "/usr/local/lib/bclib.pl";

@guidance = recent_forecast();
@querys = hashlist2sqlite([@guidance],"guidance");

debug("QUERI",@queries);

open(A,">/var/tmp/mos-queries.txt");
print A "BEGIN;\n";

for $i (@querys) {
  # REPLACE if needed
  $i=~s/IGNORE/REPLACE/;
  print A "$i;\n";
}

print A "COMMIT;\n";

# delete old reports + clean db
print A "DELETE FROM guidance WHERE timestamp < DATETIME(CURRENT_TIMESTAMP, '-3 hour');\n";
print A "VACUUM;\n";
close(A);

system("cp /sites/DB/guidance.db /sites/DB/guidance.db.new");
system("sqlite3 /sites/DB/guidance.db.new < /var/tmp/mos-queries.txt");
system("mv /sites/DB/guidance.db /sites/DB/guidance.db.old; mv /sites/DB/guidance.db.new /sites/DB/guidance.db");
