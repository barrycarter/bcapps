#!/bin/perl

# Given a FetLife user profile, returns a trimmed version with no loss
# of information, just loss of headers/etc; currently in testing

# will use diff -uwr on old and new versions to confirm loss is
# identical (and thus useless) on each file

require "/usr/local/lib/bclib.pl";

# directory where I am temporarily keeping these files, pending bzdiff
# to originals

my($target) = "/mnt/extdrive/20141229-FET";

for $i (@ARGV) {

  my($all);
  if ($i=~/\.bz2$/) {
    $all = join("", `bzcat $i`);
  } else {
    $all = read_file($i);
  }

  # kill off leading spaces
  $all=~s/^\s+//mg;

  # nothing useful pre-title
  $all=~s/^.*?<title>/<title>/s;

  # everything between that and <h2
  # $all=~s%</title>.*?<h2%</title>\n<h2%s;
  $all=~s%</title>.*?<div class="span-6">%</title>%s;

  # everything past the ads container (nope, past report user)
#  $all=~s%<div id="ads_container">.*$%%s;
  $all=~s%<section id="report_user".*$%%s;

  # kill off lines that have just a single tag with no data (except div)
#  $all=~s%^\s*</?(div|table|tr)[^>]*?>\s*$%%mg;
  $all=~s%^\s*</?(table|tr)[^>]*?>\s*$%%mg;

  # for div, can only kill off pure lines
  $all=~s%^</?div>$%%mg;

  # kill off blank lines
  $all=~s/\n+/\n/sg;

  # where I am keeping the revised versions
  my($j) = $i;
  $j=~s/\.bz2$//;
  $j=~m%/(\d{3})(\d+)$%;

  my($dir,$file) = ($1, $2);

  unless (-d "$target/$dir") {system("mkdir $target/$dir");}

  write_file($all, "$target/$dir/$dir$file");

  # bzdiff doesn't support "-r", so leaving these unbzipped for now
  # system("bzip2 $target/$dir/$dir$file");
}

# to test, use "diff -uwr" on two directories (after bunzipping the
# original) and then sort/uniq the results to see which lines show
# multiple times (ie, in each profile)
