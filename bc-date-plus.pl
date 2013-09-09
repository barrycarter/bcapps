#!/bin/perl

# Given an amount of time in the future (as years/months/days/etc) and
# a strftime format, print the future time

# This program might be totally useless given what date -d does

require "/usr/local/lib/bclib.pl";

my($amount,$format) = @ARGV;
unless ($format) {$format="%c";}

# number of seconds in various times (by first letter)
%seconds = ("s" => 1, "m" => 60, "h" => 3600, "d" => 86400,
	    "w" => 86400*7, "y" => 86400*365.2425);

# is $amount negative? (and remove sign either way)
my($sign)=1;
# remove + sign but do nothing else
$amount=~s/^\+//isg;
# remove sign and make negative
if ($amount=~s/^\-//) {$sign=-1;}

# TODO: allow for multi-character in $amount?
# start at current time and add
$res = time();
while ($amount=~s/(\d+)(\D)//) {
  # ugly to use $1,$2 directly
  $res+= $sign*$1*$seconds{$2}
}

# TODO: allow for gmtime
$result = strftime("$format\n",localtime($res));

print $result;




