#!/bin/perl

# scrapes *recent* email addresses (*initial* post less than a week old)
# off scamwarners.com (selected forums) and adds them to toping.txt

# The fora:
# 7: advance fee fraud
# 12: lottery scams
# 14: recovery scams
# 8: charity scams
# 9: financial, various

require "/usr/local/lib/bclib.pl";

# download fora first pages (only)
for $i (7,8,9,12,14) {
  my($out,$err,$res) = cache_command("curl 'http://www.scamwarners.com/forum/viewforum.php?f=$i'", "age=3600");
  debug($out);
}


