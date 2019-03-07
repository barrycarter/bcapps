#!/bin/perl

require "/usr/local/lib/bclib.pl";

my($data, $file) = cmdfile();

unless ($data=~s%<span>Ordered from</span><br/>\s*<span.*?>\s*(.*?)\s*</span>%%) {
  warn("NO MATCH REST NAME");
}

my($rest) = $1;

unless (
	$data=~s%<span>Order Details</span><br/>\s*<span>(.*?)</span>\s*<br/><span><b>(.*?)</b></span>%%
       ) {warn("NO MATCH TIME/NUM");}

my($time, $num) = ($1, $2);

my($order);

while ($data=~s%\s*(.*?)\s*<!-- (qty|item name|price) -->%%) {

  my($value, $type) = ($1, $2);

  $value=~s/\&nbsp;//;

  $order .= "$value ";

  if ($type eq "price") {$order .= "\n";}

}

while ($data=~s%<td.*?>\s*(Service fee|Estimated sales tax|Tip)\s*</td>\s*<td.*?>\s*(.*?)\s*</td>%%) {

  debug("$1, $2, ALPHA");
}


# debug("ORDER: $order");

