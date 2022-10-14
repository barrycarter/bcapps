#!/bin/perl

# attempts to parse an amazon receipt

require "/usr/local/lib/bclib.pl";

# fields I want to rename (for consistency with existing data)

%rename = ("Subscribe & Save" => "subscribe & save",
	   "Estimated tax to be collected" => "tax",
	   "Gift Card Amount" => "gift card amount"
	   );

my($data, $fname) = cmdfile();

$data=~s%<(script|style)[^>]*?>.*?</\1>%%sg;

$data=~s/<.*?>//g;

$data=~s/\n\s+/\n/sg;

$data=~s/:\n/: /sg;

$data=~s/\&amp\;/&/g;

my(%hash);

my($fields) = "Subscribe and Save Order Placed|Order Placed|Amazon.com order number|Shipped on|Sold by|Condition|Shipping Speed|Shipping Address|Subscribe \& Save|Estimated tax to be collected|Gift Card Amount|Grand Total";

while ($data=~s/($fields):? (.*)\n//) {$hash{$1} = $2;}

# print all the fields without $ first

for $i (split(/\|/, $fields)) {
  if ($hash{$i} && $hash{$i}!~/\$/) {print "$i: $hash{$i}\n\n";}
}

# now the item list
while ($data=~s/(\d+)\s+of: (.*?)\s*\$([0-9\.]+)\s+//s) {

  my($quant, $item, $price) = ($1,$2,$3);

  # price in pennies
  $price=~s/\.//;

  print "$item $quant*$price\n\n";
}

# now the extra charges (except grand total)

for $i (split(/\|/, $fields)) {
  if ($hash{$i}=~/\$/ && $i ne "Grand Total") {
    my($val) = $hash{$i};
    if ($rename{$i}) {$i = $rename{$i};}
    $val=~s/[\$\.]//g;
    print "$i: $val\n\n";
  }
}

$hash{'Grand Total'} =~s/[\$\.]//g;
print "total $hash{'Grand Total'} MUST BE CHECKED\n";

print "REMAINDER: $data";

# debug(%hash);

# debug("DATA: $data");
