#!/bin/perl

# useful only to me, parses the HTML version of Mario's Pizzeria
# receipts so I can add them to my db

require "/usr/local/lib/bclib.pl";

my($all, $file) = cmdfile();

$all=~s%<div id='orderNumTotal'.*?>(order\s*\#[\d\-]*\s+)%%is;
my($order) = $1;

# TODO: this isn't the "real" time but close enough
$all=~s%<div id='orderReadyTime'.*?>(Estimated Ready Time:\s*.*?)</div>%%;
my($time) = $1;

# they tbody for item list only, so this works
$all=~s%^.*?<tbody>%%s;
$all=~s%</tbody>.*$%%s;

# the items

my(@items);

while ($all=~s%<tr.*?>(.*?)</tr>%%s) {
  my($item) = $1;
  $item=~s/<.*?>/ /sg;
  $item=~s/\s+/ /g;
  $item=trim($item);
  push(@items, $item);
}

my($items) = join("\n", @items);

my($str) = << "MARK";
$order
$time
$items
MARK
;

$str=~s/\s*\n\s*/\n/g;
print $str;

=item comment

Info I want:

  - order number

  - order time

  - items ordered w/ cost and quantity

  - delivery fee

  - tax

  - tip

=cut

