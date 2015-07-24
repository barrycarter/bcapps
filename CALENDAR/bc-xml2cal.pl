#!/bin/perl

# one off coded deleted from bc-imp-dates.pl that I need again (to
# parse XML version of ODS files sent by Emilie C)

+my($all) = read_file("$bclib{githome}/CALENDAR/impdates.xml");
+
  +while ($all=~s%<table:table-row.*?>(.*?)</table:table-row>%%is) {
+  my($event) = $1;
+  my(@data) = ($event=~m%<table:table-cell.*?>(.*?)</table:table-cell>%isg);
+  for $i (@data) {
+    # remove HTML and trim/fix newlines (vcalendar should be ok w that)
+    $i=~s/<.*?>//g;
+    $i=~s/^\s*//;
+    $i=~s/\s*$//;
+    $i=~s/\n/\\n/g;
+    # ugly
+    $i=~s/[^ -~]//g;
+    # uglier
+    $i=~s/\&\#\d+\;//g;
+#    $i=~s/\s+/ /g;
+    # per Emilie request
+    $i=~s/international/worldwide/g;
+  }

+  for $i (0..$#fields) {$data{$data[0]}{$fields[$i]} = $data[$i];}
