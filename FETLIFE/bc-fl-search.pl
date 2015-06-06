#!/bin/perl

# Frontend to fetlife.db.94y.info that allows access to some simple queries

require "/usr/local/lib/bclib.pl";

print "Content-type: text/html\n\n";

# for now
$globopts{debug}=1;

my($options) = read_file("fl-forms.txt");

# TODO: this can and really should be subroutinized to create
# arbitrary SELECT dropdowns

$options=~s%<genders>(.*?)</genders>%%s;

my(@genders) = split(/\n/, $1);

# the wildcard option
my(@genselect) = ("<option value=\"*\">Any Gender</option>");

for $i (sort @genders) {
  # ignore non-hash (and empty)
  unless ($i=~/^(.*?):(.*)$/) {next;}
  push(@genselect, "<option value=\"$1\">$2</option>");
}

$genselect="<select name='gender'>\n".join("\n",@genselect)."\n</select>\n";

# roles are easier, list not a hash

$options=~s%<roles>(.*?)</roles>%%s;

my(@roles) = split(/\n/, $1);


my(@roleselect) = ("<option value=\"*\">Any Gender</option>");

for $i (sort @roles) {
  # ignore non-hash (and empty)
  unless ($i=~/^(.*?):(.*)$/) {next;}
  push(@roleselect, "<option value=\"$1\">$2</option>");
}

$roleselect="<select name='role'>\n".join("\n",@roleselect)."\n</select>\n";

# options for age (no one is really 99, since earliest allowed birth
# year is 1920 [which is why 95 = birth year 1920 is the "fake age" value]

my(@ages);
for $i (18..99) {push(@ages,"<option value='$i'>$i</option>");}



my($form) = << "MARK";

<form action="/bc-fl-search.pl" method="GET"><table border>

<tr><th colspan=2>UNOFFICIAL FetLife Search Form (not affiliated with FetLife)</th></tr>

<tr><th>Gender</th><td>$genselect</td></tr>
<tr><th>Age</th><td>X to X</td></tr>
<tr><th>Role</th><td>$roleselect</td></tr><tr>
<th>City</th><td><input type='text' name='city' /></td></tr>
<tr><th>State</th><td><input type='text' name='state' /></td></tr>
<tr><th>Cuntry</th><td>

MARK
;

debug("FORM: $form");


debug("GENDERS:",$genselect);

die "TESTING";





# list of countries
@cunts = `egrep -v '#' $bclib{githome}/FETLIFE/countrylist.txt`;
map(chomp($_),@cunts);

# parse query sent by user

my(@chunks)=split(/\&/,$ENV{QUERY_STRING});

webug("CHUNKS",@chunks);


# submit a query to fetlife.db.94y.info

# really should use "submit=RUN+QUERY" but ok w/below
my($query)="query=SELECT COUNT(*) FROM kinksters";

my($tmpdir) = tmpdir("bcfs");

write_file($query, "query");

my($out,$err,$res) = cache_command2("curl -L -d \@query http://post.fetlife.db.94y.info/","salt=$tmpdir");

debug("OER: $out/$err/$res");



