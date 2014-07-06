#!/bin/perl

require "/usr/local/lib/bclib.pl";

chdir("/home/barrycarter/BCGIT/METAWIKI/");

# this is fairly insane
open(A, "| sort | uniq | tee /tmp/triptake.txt");

for $i (`cat pbs.txt pbs-cl.txt | egrep -v '^#|^\$'`) {
  $i=~s/^(\S+)\s+//;
  my($dates) = $1;
  while ($i=~s/\[\[([^\[\]]*?)\]\]/\001/) {
    my(@triple) = split(/::/, $1);
    if (scalar @triple==2) {
      print A "$dates|".join("|",@triple)."|\n";
    }  elsif (scalar @triple==3) {
      print A join("|",@triple)."|$dates\n";
    } else {
      warn("WTF",@triple);
    }
    $i=~s/\001/$triple[-1]/;
  }
}

close(A);

=item parse_date_list($string)

TODO: move this to bclib

Given a string like "2013-04-17-2013-04-19, 2013-04-22, 2013-04-23,
2013-04-30, 2013-05-01, 2013-05-06-2013-05-08, 2013-05-13-2013-05-15,
2013-05-20-2013-05-22, 2013-05-24, 2013-05-29", return a list of dates.

=cut

sub parse_date_list {
  my($datelist) = @_;
  my(@ret);

  for $i (split(/\,/,$datelist)) {
    # if datelist is date range (2002-06-03-2002-06-07), parse further
    if ($i=~/^(\d{4}-\d{2}-\d{2})\-(\d{4}-\d{2}-\d{2})$/) {
      for $j (str2time($1)/86400..str2time($2)/86400) {
	push(@ret, strftime("%Y-%m-%d", gmtime($j*86400)));
      }
    } else {
      push(@ret, $i);
    }
  }
  return @ret;
}
