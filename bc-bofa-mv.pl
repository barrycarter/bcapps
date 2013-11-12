#!/bin/perl

# renames (or confirms name of) many different types of bank/financial
# files, using text version of their PDF files

# TODO: check for missing statements, report first and last statements

require "/usr/local/lib/bclib.pl";

for $i (@ARGV) {
  debug("I: $i");
  unless (-f "$i.txt") {warnlocal("NO TEXT VERSION: $i"); next;}
  $all = read_file("$i.txt");

  # centurylink
  if ($all=~/CenturyLink/s) {
    $fname = handle_centurylink($all);
  } elsif ($all=~/www\.ally\.com/) {
    $fname = handle_ally($all);
  } elsif ($all=~/pnm\.com/i) {
    $fname = handle_pnm($all);
  } elsif ($all=~/vanguard\.com/) {
    $fname = handle_vanguard($all);
  } else {
    warnlocal("Cannot rename: $i");
    next;
  }

  unless ($fname) {
    warnlocal("NO CONVERSION: $i");
    next;
  }

  # if filename already correct, do nothing
  if ($i eq $fname) {next;}
  # otherwise, advise move
  print "mv $i $fname\n";

}

sub handle_vanguard {
  my($all) = @_;
  my($date);

  if ($all=~/(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)(.*?\d{4})\,*\s+year-to-date/im) {
    $date = "$1$2";
  } elsif ($all=~/ending balance on ([\d\/]+)/is) {
    $date = $1;
  } else {
    warnlocal("CANNOT PARSE!");
    return;
  }

  return strftime("vanguard-%m-%d-%Y.pdf", gmtime(str2time($date)));
}

sub handle_pnm {
  my($all) = @_;
  my($date);

  if ($all =~/([\d\/]+)\s+1 of/) {
    $date = $1;
  } elsif ($all=~/Bill Date\s+(.*?)\s+/s) {
    $date = $1;
  } else {
    warnlocal("CANNOT PARSE!");
    return;
  }

  return strftime("PNM-%m-%d-%Y.pdf", gmtime(str2time($date)));
}

sub handle_ally {
  my($all) = @_;
  my($date);

  if ($all=~/Statement Period [\d\/]+\s+\-\s+([\d\/]+)/) {
    $date = $1;
  } elsif ($all=~/Statement Date\s+([\d\/]+)/) {
    $date = $1;
  } else {
    warnlocal("CANNOT PARSE!");
    return;
  }

  # ally dates their statements one day ahead
  return strftime("ally-%m-%d-%Y.pdf", gmtime(str2time($date)+86400));
}

sub handle_centurylink {
  my($all) = @_;

  $all=~/Billing Date (.*?)$/m;
  my($date) = $1;
  return strftime("centurylink-%m-%d-%Y.pdf", gmtime(str2time($date)));
}

die "TESTING";

# renames bank of america pdf files based on account number and closing date
# Account Number: [digits and spaces]
# Statement Period 12-12-07 through 01-11-08 [latter date counts]

require "/usr/local/lib/bclib.pl";
$ENV{TZ}="UTC";

for $i (@ARGV) {
  my($acct,$date) = get_acct_date(join("\n",`pdftotext '$i' - 2> /dev/null`));
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
  print "mv '$i' $date\n";
}

# check for gaps in months for accounts
for $i (keys %months) {
  my(@months) = sort {$a <=> $b} keys %{$months{$i}};
  debug("$i -> ",@months);
  $monthrange = $months[$#months]-$months[0];
  $missing = $monthrange-$#months;
  if ($missing) {
    warn("MISSING STATEMENTS: $i ($missing; $months[0]-$months[$#months] with only $#months+1 entries)");
  }
}

# obtains date and account number from text version of bofa pdf file

sub get_acct_date {
  my($text) = @_;
  my($acct,$date);

  # can't handle tax statements
  if ($text=~/1099-INT/i) {return;}

  # combined statements
  if ($text=~s/combined statement page \d+ of \d+ (\d+) statement period .*? through ([\d\-]+)//is) {
    ($acct,$date) = ($1,$2);
    debug("COMBINED STATEMENT");
    return $acct,$date;
  }

  # account number and date on same line
  if ($text=~s/account number: ([\d ]+)(.*?)account information://is) {
    ($acct,$date) = ($1,$2);
    $acct=~s/ //isg;
    $date=~s/^.*\-\s+//;
    debug("CASE ALPHA: $date");
    # if $date is super long, this is an error
    if (length($date)>50) {return;}
    return $acct,$date;
  }

  # similar case as above
  if ($text=~s/account\s+\#\s+([\d ]+)[\|\!](.*?)important\s+information://is) {
    ($acct,$date) = ($1,$2);
    $acct=~s/ //isg;
    $date=~s/^.*to\s+//;
    debug("CASE BETA");
    return $acct,$date;
  }

  # find account number
  $text=~s/account number:([ \d]+)//is;
  $acct = $1;
  $acct=~s/\s//isg;
  # end period
  $text=~s/statement period .* through (\d{2}\-\d{2}\-\d{2})//is;
  $date = $1;
  debug("CASE GAMMA");
  # return (may be empty, but caller will handle)
  return $acct,$date;
}
