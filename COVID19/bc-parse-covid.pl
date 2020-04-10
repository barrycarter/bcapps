#!/bin/perl

require "/usr/local/lib/bclib.pl";

my(@data) = split(/\r\n/,read_file("/home/user/COVID-19/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv"));

@headers = csv(shift(@data));

# $data{place}{date} = # of incidents on that day in place
my(%data);
my($name);

for $i (@data) {

    my(@cols) = csv($i);

    my(%colhash);

    for $j (0..$#headers) {

	if ($headers[$j] =~m%(\d+/\d+/\d+)%) {
#	    $data{$name}{$headers[$j]} = $cols[$j];
	    next;
	}

	# header is not date
	$colhash{$headers[$j]} = $cols[$j];
    }
}

for $i (sort keys %data) {
    debug("I: $i");
}

# my($hashlist) = arraywheaders2hashlist([map(s/\r\n//g; $_=[csv($_)], @conf)]);

#for $i (@$hashlist) {
#    for $j (sort keys %$i) {
#	debug("$j $i->{$j}");
#    }
# }

