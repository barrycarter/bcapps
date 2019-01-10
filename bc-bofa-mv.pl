#!/bin/perl

# renames (or confirms name of) many different types of bank/financial
# files, using text version of their PDF files

# TODO: check for missing statements, report first and last statements
# TODO: could really write this more generically with regexs in file

require "/usr/local/lib/bclib.pl";

for $i (@ARGV) {
  debug("I: $i");

  # for some, it might be possible to get directly from PDF
  my($pdf) = read_file($i);

  unless (-f "$i.txt") {warnlocal("NO TEXT VERSION: $i"); next;}
  $all = read_file("$i.txt");

  # TODO: should add check that txt is more recent than PDF

#  debug("ALL: $all");

  # switch based on pdf or txt contents
  if ($all=~/CenturyLink/s) {
    $fname = handle_centurylink($all);
  } elsif ($all=~/bluebird/i) {
    $fname = handle_bluebird($all);
  } elsif ($all=~/capitalone/i) {
    # this test MUST come before COMCAST test because I bill COMCAST to capone
    $fname = handle_capone($all);
  } elsif ($all=~/compass/i) {
    $fname = handle_compass($all);
  } elsif ($all=~/www\.ally\.com/) {
    $fname = handle_ally($all);
  } elsif ($all=~/pnm\.com/i) {
    $fname = handle_pnm($all);
  } elsif ($pdf=~/Registered to: VANGUARD/m || $all=~/Vanguard Voyager Services/m) {
    $fname = handle_vanguard($all);
  } elsif ($all=~/PayPal Account ID/) {
    $fname = handle_paypal($all);
  } elsif ($all=~/nmefcu/i) {
    $fname = handle_nmefcu($all);
  } elsif ($all=~/www\.mtb\.com/i) {
    $fname = handle_mtb($all);
  } elsif ($all=~/COMCAST/) {
    # TODO: this catches statements where comcast is listed = bad
    $fname = handle_comcast($all);
  } elsif ($all=~/samsclub/) {
    $fname = handle_samsclub($all);
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

sub handle_bluebird {
  my($all) = @_;

  $all=~/Card Number Ending in\s*\-\s*(\d+)$/m||warnlocal("BAD CARD#");;
  my($num) = $1;

  $all=~m%Statement Period \d{2}/\d{2}/\d{4} through (\d{2})/(\d{2})/(\d{4})$%m || warnlocal("BAD DATE");

  my($fname) = strftime("bluebird-$num-%m-%d-%Y.pdf", gmtime(str2time("$3-$1-$2")));

  return $fname;
}

sub handle_capone {
  my($all) = @_;

#  $all=~/([A-Z][a-z][a-z]\.\s+\d{2})\s+\-\+.*?,\s+(\d+)/s;
  $all=~/[A-Z][a-z][a-z]\.\s+\d{2}\s+\-\s+([A-Z][a-z][a-z]\.\s+\d{2},\s+\d+)/s;
  return strftime("capone-%m-%d-%Y.pdf", gmtime(str2time($1)));
}

sub handle_samsclub {
  my($all) = @_;
  # first mm/dd/yyyy after "closing date"
  $all=~m%closing date.*?(\d{2})/(\d{2})/(\d{4})%is;
  return "samsclub-$1-$2-$3.pdf";
}

sub handle_compass {
  my($all) = @_;
  $all=~/Account Summary for Period.*?\-\s*(.*?)\s*Summary of Account/;
  return strftime("compass-%m-%d-%Y.pdf", gmtime(str2time($1)+43200));
}

sub handle_comcast {
  my($all) = @_;

  debug("ALL: $all");

  # TODO: editing so this works w/ current bills, but should retroact
  # TODO: this is now bill date, not due date
  $all=~m%(Bill|Billing) [Dd]ate\s*(.*?)\n%s;
  my($date) = $2;
  debug("DATE: $date");

  return strftime("comcast-%m-%d-%Y.pdf", gmtime(str2time($date)+43200));

  # first date is billing date
#  $all=~m%(\d{2})/(\d{2})/(\d{2})%;
#  return "comcast-$1-$2-20$3.pdf";
}

sub handle_mtb {
  my($all) = @_;

  $all=~m%statement date:\s*(\d{2})/(\d{2})/(\d{2})\s+%is;
  return "mtb-$1-$2-$3.pdf";
}

sub handle_nmefcu {
  my($all) = @_;

  # \xe2\x88\x92 now means "-", apparently
  $all=~s/\xe2\x88\x92/-/isg;

  # new format ~ Mar 2014
  if ($all=~/ending date: ([\d\-]+)/is) {
    $date = $1;
  } elsif ($all=~/[\d\-]+\s*THRU\s*([\d\-]+)/) {
    # <h>Remember when THRU wasn't a word?</h>
    $date = $1;
  } else {
    warnlocal("CANNOT PARSE NMEFCU DATE");
  }

  return strftime("nmefcu-%m-%d-%Y.pdf", gmtime(str2time($date)+43200));
}

sub handle_paypal {
  my($all) = @_;
  my($date, $email);

  debug("ALL HERE: $all");

  # testing
#  if ($all=~/Statement period:\n?.*?-\s*(.*)$/im) {debug("1 is: $1");}

  if ($all=~/Statement period:\n?.*?\-\s*(.*)$/im) {
    $date = $1;
  } else {
    warnlocal("CANNOT PARSE PAYPAL DATE");
    return;
  }

  # because I have multiple accounts now...
  if ($all=~/Email \(PayPal Account ID\): (.*?)$/im) {
    $email = $1;
  } else {
    warnlocal("CANNOT PARSE EMAIL ADDR");
    return;
  }

  return strftime("paypal-$email-%m-%d-%Y.pdf", gmtime(str2time($date)+43200));
}

sub handle_vanguard {
  my($all) = @_;
  debug("VANGUARD CALLED");

  # first three words
  $all=~/^([A-Z][a-z]+\s+\d+\s*,\s*\d+)/s;
  return strftime("vanguard-%m-%d-%Y.pdf", gmtime(str2time($1)+43200));
}

sub handle_pnm {
  my($all) = @_;
  my($date);

  if ($all =~/([\d\/]+)\s+1 of/) {
    $date = $1;
#  } elsif ($all=~/Bill Date\s+(.*?)\s+/s) {
  } elsif ($all=~/Bill (?:Date|Issued:)\s+(.*?)\s+/s) {
    $date = $1;
    debug("DATE: $date");
  } else {
    warnlocal("CANNOT PARSE PNM!");
    return;
  }

  return strftime("PNM-%m-%d-%Y.pdf", gmtime(str2time($date)));
}

sub handle_ally {
  my($all) = @_;
  my($date);

  debug("HANDLE_ALLY() CALLED");

  if ($all=~/Statement Period [\d\/]+\s+\-\s+([\d\/]+)/s) {
    $date = $1;
  } elsif ($all=~/Statement Date\s+([\d\/]+)/s) {
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
