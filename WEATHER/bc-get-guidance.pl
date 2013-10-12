#!/bin/perl

# trivial wrapper around recent_forecast() to populate db
# this is run via cron since guidance is infrequently updated

require "/usr/local/lib/bclib.pl";

@guidance = recent_forecast();
@querys = hashlist2sqlite([@guidance],"guidance");

# write queries to time-based file for bc-query-gobbler
my($daten) = `date +%Y%m%d.%H%M%S.%N`;
chomp($daten);
my($qfile) = "/var/tmp/querys/$daten-madis-$$";

open(A,">$qfile");
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
