#!/bin/perl

# Frontend to fetlife.db.94y.info that allows access to some simple queries

require "/usr/local/lib/bclib.pl";

# options for age (no one is really 99, but I know that's a safe value)

my(@ages);
for $i (18..99) {push(@ages,"<option value='$i'>$i</option>");}

# list of countries
@cunts = `egrep -v '#' $bclib{githome}/FETLIFE/countrylist.txt`;
map(chomp($_),@cunts);


