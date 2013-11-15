#!/bin/perl

# renames (or confirms name of) many different types of bank/financial
# files, using text version of their PDF files

# TODO: check for missing statements, report first and last statements
# TODO: could really write this more generically with regexs in file



require "/usr/local/lib/bclib.pl";

for $i (@ARGV) {
  debug("I: $i");

  # for vanguard, it might be possible to get directly from PDF
  my($pdf) = read_file($i);

  unless (-f "$i.txt") {warnlocal("NO TEXT VERSION: $i"); next;}
  $all = read_file("$i.txt");

  # switch based on pdf or txt contents
  if ($all=~/CenturyLink/s) {
    $fname = handle_centurylink($all);
  } elsif ($all=~/www\.ally\.com/) {
    $fname = handle_ally($all);
  } elsif ($all=~/pnm\.com/i) {
    $fname = handle_pnm($all);
  } elsif ($pdf=~/^%%DOC.*RPSS\d+[A-Z]\d+/m) {
    # TODO: are there non vanguard documents with the regex above?
    $fname = handle_vanguard($pdf);
  } elsif ($all=~/PayPal Account ID/) {
    $fname = handle_paypal($all);
  } elsif ($all=~/nmefcu/i) {
    $fname = handle_nmefcu($all);
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
  # is someone else using this fname?
  if (-f $fname) {
    warn "can't mv $i $fname; target already exists";
    next;
  }
  # do I plan to given someone else this filname already?
  if ($target{$fname}) {
    warn "can't mv $i $fname; already plan to move other file there";
    next;
  }
  $target{$fname} = 1;
  # otherwise, advise move
  print "mv -i $i $fname\n";

}

sub handle_nmefcu {
  my($all) = @_;

  # <h>Remember when THRU wasn't a word?</h>
  if ($all=~/[\d\-]+\s*THRU\s*([\d\-]+)/) {
    $date = $1;
  } else {
    warnlocal("CANNOT PARSE NMEFCU DATE");
  }

  return strftime("nmefcu-%m-%d-%Y.pdf", gmtime(str2time($date)+43200));
}

sub handle_paypal {
  my($all) = @_;

  if ($all=~/Statement period:.*?\-\s*(.*)$/m) {
    $date = $1;
  } else {
    warnlocal("CANNOT PARSE PAYPAL DATE");
    return;
  }

  return strftime("paypal-%m-%d-%Y.pdf", gmtime(str2time($date)+43200));
}

sub handle_vanguard {
  my($pdf) = @_;

  # look for odd code (must be caps)
  unless ($pdf=~/^%%DOC.*RPSS\d+[A-Z](\d+)/m) {
    warnlocal("NO MATCH IN $i");
    return;
  }

  return strftime("vanguard-%m-%d-%Y.pdf", gmtime(str2time($1)+43200)); 

return;


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

# TODO: add bofa code from below
# TODO: add gap checking code from below
die "TESTING";

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
