#!/usr/bin/perl

# Usage: $0 --amount=a --months=m --rate=r --fee=f --minmonth=mm, where:
# a = amount borrowed in dollars
# m = months for which the interest rate 'r' is valid
# r = the interest rate (usually a special rate for cash advances)
# f = the cash advance fee as percentage of money borrowed
# mm = the minimum monthly payment, as a %age of the total balance

# if you borrow from your credit card and they have a cash advance fee
# and/or minimum monthly payment, this is the APR you'd need to break
# even, ie, the "true interest rate"

# This program is from my older work, and thus worse than usual

# Will eventually run at apr.barrycarter.info

require "bclib.pl";

$advance = $globopts{fee}*$globopts{amount};
$params = "amount=$globopts{amount}&months=$globopts{months}&rate=$globopts{rate}&fee=$advance&minmonth=$globopts{minmonth}";

# checks (not sure these are all necessary)

if ($globopts{amount}<1 || $globopts{amount}>1e+6) {
  sorry("Amount borrowed must be between \$1 and \$999,999");
}

if ($globopts{months}<1 || $globopts{months}>480) {
  sorry("Length of loan must be between 1 and 480 months");
}

 if ($globopts{rate}<-.99 || $globopts{rate}>.99) {
  sorry("Loan APR must be between -.99 and +.99");
}

if ($globopts{minmonth}<0 || $globopts{minmonth}>.99) {
  sorry("Minimum monthly payment must be between 0 and +.99");
}

# trivial function for findroot (find interest rate so sinking table
# ends with 0 [ie, no profit/gain])

sub f {return sinking_table("$params&gainonly=1&investrate=$_[0]");}

$res = findroot(\&f,0,1,1e-6,100);

# this is redundant, since we calculate it as part of findroot
@res = sinking_table("$params&investrate=$res");

# print the table and true interest rate
printf("<b>True interest rate</b>: %0.3f%%<p>\n", $res*100);

print << "MARK";

<table border>
<tr>
<th>Month</th>
<th>Owed at start of month</th>
<th>Interest on money owed</th>
<th>Minimum payment to credit card</th>
<th>Owed at end of month</th>
<th>&nbsp;</th>
<th>Money in hand at start of month</th>
<th>Return on money in hand</th>
<th>Minimum payment to credit card</th>
<th>Money in hand at end of month</th>
<th>&nbsp;</th>
<th>Equity (money in hand minus money owed)</th>
</tr>

MARK
;

for $i (0..$#res) {
  debug("HASH START: $i");
  %hash = %{$res[$i]};

  print "<tr>\n";

  # month not printed in monetary format, so just do it here
  print "<td>$i</td>\n";

  for $j ("oldowed", "owedint", "-payment", "owed", "",
	  "oldhave", "haveprof", "-payment", "have", "", "gain") {

    # print blanks
    if ($j eq "") {print "<td>&nbsp;</td>\n"; next;}

    # the amount to print
    $key = $j;
    if ($key=~s/^\-//) {$pr=-$hash{$key};} else {$pr=$hash{$key};}

    # print it
    print "<td>".money_print($pr)."</td>\n";
  }

  print "</tr>\n";
}

print "</table>\n";

=item sinking_table()

Returns sinking table (as list of hashes) for loan w/ following parameters:

amount - the amount in dollars (eg, 10000)
rate - the annual interest rate (eg, .05)
fee - upfront fee in dollars (eg, 300)
months - length of loan in months (eg, 60)
minmonth - percentage minimum payment per month (eg, .02)
investrate - the rate at which the borrowed money is invested (eg, .06)
gainonly - if set, return only final gain, nothing else

=cut

sub sinking_table {
  my(%VALUE) = parse_form($_[0]);

  debug("alpha",unfold(%VALUE),"/alpha");

  my($oldowed, $oldhave, $owedint, $payment, $haveprof, $gain);
  my(@res);

  # start out owing amount + fee
  my($owed) = $VALUE{amount} + $VALUE{fee};
  # start out having amount
  my($have) = $VALUE{amount};

  # iterate thru months
  for $i (0..$VALUE{months}) {

    # before values
    $oldowed = $owed;
    $oldhave = $have;

    # interest on money you owe
    $owedint = $owed*((1.+$VALUE{rate})**(1./12.)-1.);

    # payment you make monthly
    # HACK: TODO: if minmonth>1 assume it's a dollar amount
    if (abs($VALUE{minmonth}) < 1) {
      $payment = $owed*$VALUE{minmonth};
    } else {
      $payment = $VALUE{minmonth};
    }

    # profit from investment
    $haveprof = $have*((1.+$VALUE{investrate})**(1./12.)-1.);

    # subtract from owed/have
    $owed += $owedint-$payment;
    $have += $haveprof-$payment;
    $gain = $have-$owed;

    # really odd way of doing this
    my(%hash) = parse_form("oldowed=$oldowed&oldhave=$oldhave&owedint=$owedint&payment=$payment&haveprof=$haveprof&owed=$owed&have=$have&gain=$gain");
    push(@res,\%hash);
  }

  if ($VALUE{gainonly}) {return $gain;}
  return @res;
}

# how to print monetary amounts for this prog

sub money_print {
  my($val) = @_;
  $val=sprintf("%0.2f",$val);
  if ($val<0) {
    $val=~s/^\-//;
    $val="<font color='#ff0000'>-\$$val</font>";
  } else {
    $val="\$$val";
  }
    return $val;
}

# how to display errors
sub sorry {
  my($err) = @_;
  print "<b><font color='#ff0000'>Error: $err</font></b>\n";
  exit(-1);
}
