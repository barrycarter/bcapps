#!/bin/perl

# Frontend to fetlife.db.94y.info that allows access to some simple queries

require "/usr/local/lib/bclib.pl";


print "Content-type: text/html\n\n";

print "Q: $ENV{QUERY_STRING}";

# options for age (no one is really 99, but I know that's a safe value)

my(@ages);
for $i (18..99) {push(@ages,"<option value='$i'>$i</option>");}

# list of countries
@cunts = `egrep -v '#' $bclib{githome}/FETLIFE/countrylist.txt`;
map(chomp($_),@cunts);


# submit a query to fetlife.db.94y.info

# really should use "submit=RUN+QUERY" but ok w/below
my($query)="query=SELECT COUNT(*) FROM kinksters&submit=1";

my($tmpdir) = tmpdir("bcfs");

write_file($query, "query");

my($out,$err,$res) = cache_command2("curl -L -d \@query http://post.fetlife.db.94y.info/","salt=$tmpdir");

debug("OER: $out/$err/$res");



