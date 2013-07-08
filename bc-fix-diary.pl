#!/bin/perl

# bc-walkaround.pl has an error that sometimes puts tomorrow's replies
# into today's "diary" file (if the alert occurs before midnight, but
# the reply occurs after midnight). This attempts to fix those diary
# files where this occurs

require "/usr/local/lib/bclib.pl";

# NOTE: because each day may affect the day AFTER it, this loop must
# work in reverse, latest to earliest

# TODO: stopping at july 1st for now, but go back further
for ($i=time(); $i>=str2time("2013-01-01 00:00:00 MDT"); $i-=86400) {
  $file = strftime("/home/barrycarter/TODAY/%Y%m%d.txt",localtime($i));
  # next days file (since we'll be adding to it, maybe)
  $tommfile = strftime("/home/barrycarter/TODAY/%Y%m%d.txt",localtime($i+86400));
  $lastreading = 0;
  open(A,$file)||die("Can't open $file, $!");
  # this is the output file (we don't alter originals)
  open(B,">$file.new")||die("Can't open $file.new, $!");
  while (<A>) {
    # ignore blanks, but print them to output file
    if (/^\s*$/) {
      print B $_;
      next;
    }

    # obtain the timestamp (first field)
    $tstamp = $_;
    $tstamp=~s/\s.*$//isg;

    # if tstamp is in order, everything is good
    if ($tstamp >= $lastreading) {
      print B $_;
      $lastreading = $tstamp;
      next;
    }

    # tstamp is out of order, append to start of next days file (this
    # SHOULD keep next days file in order because of the error types I
    # expect; if it DOESNT, I have more serious problems, and need to
    # know about them).
    # There's no good way to prepend to a file, but this works
    open(C,">$tommfile.new.new");
    print C $_;
    close(C);
    system("cat $tommfile.new >> $tommfile.new.new");
    system("mv $tommfile.new.new $tommfile.new");
  }
  close(A);
  close(B);
}

=item testing

Testing that no data has been lost:

\cat 2013????.txt.new | sort >! bigfile1
\cat 2013????.txt | sort >! bigfile2
diff bigfile[12];: empty as expected

Confirm that the .new files are now in order (if not, more serious
problems have occurred; only compare first field) [pipe to shell]:

\ls 2013*.txt.new|perl -nle 'print "echo $_;egrep -v \47\^\$\47 $_|sort -c -k1,1 -s"'

=cut
