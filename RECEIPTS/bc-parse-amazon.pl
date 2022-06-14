#!/bin/perl

# attempts to parse an amazon receipt

require "/usr/local/lib/bclib.pl";

my($data, $fname) = cmdfile();

$data=~s%<(script|style)[^>]*?>.*?</\1>%%sg;

$data=~s/<.*?>//g;

$data=~s/\n\s+/\n/sg;

$data=~s/:\n/: /sg;

my(%hash);

my($fields) = "Order Placed|Amazon.com order number|Shipped on|Sold by|Condition|Shipping Speed";

while ($data=~s/($fields):? (.*)\n//) {$hash{$1} = $2;}


for $i (split(/\|/, $fields)) {
  if ($hash{$i}) {print "$i: $hash{$i}\n\n";}
}

print "REMAINDER: $data";

# debug(%hash);

# debug("DATA: $data");

=item comments

Order Placed:
Amazon.com order number:
Shipped on 
Sold by:
Condition:
Shipping Address:
Shipping Speed:






=end
