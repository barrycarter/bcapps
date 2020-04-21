#!/bin/perl

require "/usr/local/lib/bclib.pl";
require "$bclib{githome}/API/bc-api-functions.pl";

print "Access-Control-Allow-Origin: *\n";

# NOTE: job of bcapi_* functions is to change the %output hash, not
# return anything

# TODO: restore to application/json
# print "Content-type: application/json\n\n";

print "Content-type: text/plain\n\n";

# NOTE: for testing, setenv QUERY_STRING ...

# TODO: restrict which characters allowed in QUERY_STRING, return
# fixed error if bad

# get the query string (can be used globally, so use globopts)

# my(%globopts) = str2hash($ENV{QUERY_STRING});

# QUERY_STRING can be overwritten by options in the command-line version

defaults($ENV{QUERY_STRING});

# the output of the function (can be used globally)

my(%output);

# the result will always contain a copy of the input...

my(%result);

$result{input} = \%globopts;

# figure out what function to call and if it exists and then call it

# debug("D", defined(&{"bcapi_time"}), defined(&{"nossdfada"}), "/D");

my($f) = "bcapi_$globopts{f}";

# now that we know the function, remove it from hash (TODO: bad idea?)
# so it won't confuse called function

delete($globopts{f});

unless (defined(&{$f})) {
    # TODO: cleaner exit for functions that dont exist
    die("$f not defined");
}

# call the function, it will change %output

&$f;

$result{output} = \%output;

print JSON::to_json(\%result),"\n";

=item bcapi_terminator(%hash)

Given the following, return a terminator of a planet assuming the
light source is the Sun:

i: naif_id
t: time in unix seconds
n: number of points
u: if 0, penumbral terminator

=cut

sub bcapi_terminator {

    # remove bad characters
    for $i (keys %globopts) {
	if ($globopts{$i}=~m/\D/) {
	    $output{error} .= "All arguments to $globopts{f} must be numeric, but $i -> $globopts{$i} is not";
	    return;
	}
    }

    my($time) = time();

    defaults("i=301&t=$time&n=100&u=1");

    if ($i == 399) {
	$output{warning} .= "Refraction not computed, results may be especially inaccurate for Earth";
    }

    my($out, $err, $res) = cache_command("/home/user/bin/bc-terminator -i $globopts{i} -t $globopts{t} -n $globopts{n} -u $globopts{u}");

    $output{order} = "lng,lat";

    for $i (split(/\n/, $out)) {
	if ($i=~/lng(\d+)=(.*?)\&lat(\d+)=(.*?)\&/) {
	    @{$output{points}}[$1] = [$2, $4];
	} else {
	    my(%hash) = str2hash($i);
	    $output{data} = \%hash;
	}
    }
}

# TODO: properly document this

# gives time in a given timezone
# tz = time zone

sub bcapi_time {

    if ($globopts{tz}=~s/[^a-z0-9\/]//isg) {
	$output{error} .= "Invalid characters in your timezone were removed";
    }

    # check if file exists
    unless (-f "/usr/share/zoneinfo/$globopts{tz}") {
	$output{error} .= "Timezone $globopts{tz} does not exist";
	return;
    }

    $ENV{TZ} = $globopts{tz};

    $output{date} = `date`;
    chomp($output{date});
}
