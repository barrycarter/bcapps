#!/usr/bin/perl

# Runs nightly and cleans up the previous days XWD files (as described below)

require "/usr/local/lib/bclib.pl";

system("/usr/bin/renice 19 -p $$");
dodie("chdir('/home/user/XWD/')");

$date = $ARGV[0];

# figure out most recent date that hasn't been done yet, allows catchup

unless ($date) {

  # TODO: this is ugly, but handles timezones ok, hopefully
  my($today) = `date +%Y%m%d`;
  chomp($today);

  # find newest file in ~/XWD that isn't today
  my(@files) = `ls -t`;

  for $i (@files) {

    # ignore dirs quietly
    if (-d $i) {next;}

    unless ($i=~/^pic\.(\d{8}):\d{6}\.png$/) {
      warn("BAD FILE: $i");
      next;
    }

    $date = $1;
    debug("LOOKING AT: $i, $date < $today?");
    if ($date < $today) {last;}
  }

  # unless date is less than today, die
  unless ($date < $today) {die "LAST DATE: $date < $today";}

  debug("USING DATE: $date");
}

# it's ok for these to fail in case it's already been done
system("mkdir $date");
system("mv pic.$date:*.png $date");
dodie("chdir('/home/user/XWD/$date')");
defaults("xmessage=1");

# run tesseract and convert on all files in directory (convert to .pnm
# because ZPAQ compresses this most efficiently)

# TODO: figure out optimal value here
# reduced to 1 (ie, no affect) so I could run it in bg w/o killing CPU
open(A,"|parallel -j 1");

# TODO: exclude cases where result already exists!

for $i (glob "*.png") {

  # as of 1 Aug 2017, no longer convert to PNM
  # unless (-f "$i.pnm") {print A "convert $i $i.pnm\n";}
  # below automatically adds .txt extension, doesn't overwrite
  unless (-f "$i.txt" || -f "/home/user/XWD2OCR/$date/$i.txt") {
    print A "tesseract $i $i\n";
  }
}

close(A);

# and move tesseract files out of the way
system("mkdir /home/user/XWD2OCR/$date");
system("mv *.txt /home/user/XWD2OCR/$date/");

# TODO: add zpaq'ing

# do a command or die

sub dodie_cmd {
  my($cmd) = @_;

  my($out, $err, $res) = cache_command2($cmd, "age=0");

  if ($res) {die "FAILED: $cmd, ERR: $err, OUT: $out";}
}
