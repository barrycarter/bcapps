#!/bin/perl

# filters out dates I need/want from gcal

# TODO: add DST start/end times, gcal does NOT have these?

require "/usr/local/lib/bclib.pl";

# find all holiday-like options
my(@options) = `gcal -hh | egrep -- '-holidays|-months' | egrep -v 'cc-holidays|include-holidays'`;
map(s/\s//g, @options);
my($options) = join(" ", @options);
my(@cal);

for $y (2014..2029) {
  push(@cal,`gcal --holiday-list=long -u $options $y | sort | uniq`);
}

debug(@cal);


