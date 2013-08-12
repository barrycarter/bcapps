#!/bin/perl

# renames bank of america pdf files based on account number and closing date
# Account Number: [digits and spaces]
# Statement Period 12-12-07 through 01-11-08 [latter date counts]

require "/usr/local/lib/bclib.pl";
$ENV{TZ}="UTC";

for $i (@ARGV) {
  # convert to text
  my($text) = join("\n",`pdftotext $i -`);
  # TODO: handle combined statements (if possible)
  if ($text=~/combined statement/i) {next;}
  # find account number
  $text=~s/account number:([ \d]+)//is;
  my($acct) = $1;
  debug("ACCT: $acct");
  $acct=~s/\s//isg;
  # end period
  $text=~s/statement period .* through (\d{2}\-\d{2}\-\d{2})//is;
  my($date) = $1;
  # if unable to find one or other, skip
  unless ($acct && $date) {next;}
  $date = lc(strftime("%b%Y-$acct.pdf",gmtime(str2time($date))));
  print "mv $i $date\n";
}
