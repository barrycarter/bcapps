#!/bin/perl

# renames bank of america pdf files based on account number and closing date
# Account Number: [digits and spaces]
# Statement Period 12-12-07 through 01-11-08 [latter date counts]

require "/usr/local/lib/bclib.pl";
$ENV{TZ}="UTC";

for $i (@ARGV) {
  my($acct,$date) = get_acct_date(join("\n",`pdftotext $i - 2> /dev/null`));
  unless ($acct && $date) {next;}
  @date = gmtime(str2time($date));
  $date = lc(strftime("%b%Y-$acct.pdf",@date));
  # TODO: check that we have RECENT statements too
  # record that we have a statement for this month for this account
  # TODO: there HAS to be a better way of doing below!
  my($month) = strftime("%Y",@date)*12+strftime("%m",@date);
  $months{$acct}{$month}=1;
  # filenames already equal?
  if ($i eq $date) {next;}
  print "mv $i $date\n";
}

# check for gaps in months for accounts
for $i (keys %months) {
  my(@months) = sort keys %{$months{$i}};
  debug("$i -> ",@months);
  $monthrange = $months[$#months]-$months[0];
  $missing = $monthrange-$#months;
  if ($missing) {
    warn("MISSING STATEMENTS: $i ($missing)");
  }
}

# obtains date and account number from text version of bofa pdf file

sub get_acct_date {
  my($text) = @_;
  my($acct,$date);

  # TODO: handle combined statements and maybe 1099-INTs
  if ($text=~/combined statement|1099-INT/i) {return;}

  # account number and date on same line
  if ($text=~s/account number: ([\d ]+)(.*?)account information://is) {
    ($acct,$date) = ($1,$2);
    $acct=~s/ //isg;
    $date=~s/^.*\-\s+//;
    return $acct,$date;
  }

  # similar case as above
  if ($text=~s/account\s+\#\s+([\d ]+)[\|\!](.*?)important\s+information://is) {
    ($acct,$date) = ($1,$2);
    $acct=~s/ //isg;
    $date=~s/^.*to\s+//;
    return $acct,$date;
  }

  # find account number
  $text=~s/account number:([ \d]+)//is;
  $acct = $1;
  $acct=~s/\s//isg;
  # end period
  $text=~s/statement period .* through (\d{2}\-\d{2}\-\d{2})//is;
  $date = $1;
  # return (may be empty, but caller will handle)
  return $acct,$date;
}
