#!/bin/perl

require "/usr/local/lib/bclib.pl";

print "Access-Control-Allow-Origin: *\n";

# TODO: restore to application/json
# print "Content-type: application/json\n\n";

print "Content-type: text/plain\n\n";

# NOTE: for testing, setenv QUERY_STRING ...

# get the query string (can be used globally)

my(%query) = str2hash($ENV{QUERY_STRING});

# the output of the function (can be used globally)

my(%output);

# the result will always contain a copy of the input...

my(%result);

$result{input} = \%query;

# figure out what function to call and if it exists and then call it

# debug("D", defined(&{"bcapi_time"}), defined(&{"nossdfada"}), "/D");

my($f) = "bcapi_$result{input}{f}";

unless (defined(&{$f})) {
    # TODO: cleaner exit for functions that dont exist
    die("$f not defined");
}

$result{output} = {&$f};

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

    my(%hash) = @_;

    # remove bad characters
    for $i (keys %hash) {$hash{$i}=~s/\D//g;}

    my($out, $err, $res) = cache_command("/home/user/bin/bc-terminator -i $hash{i} -t $hash{t} -n $hash{n} -u $hash{u}");

    print "RESULT: $out, ERR: $err, RES: $res";
}

# TODO: properly document this

# gives time in a given timezone
# tz = time zone

sub bcapi_time {

    my(%ret);

    if ($query{tz}=~s/[^a-z0-9\/]//isg) {
	$ret{error} .= "Invalid characters in your timezone were removed";
    }

    $ENV{TZ} = $query{tz};

    $ret{date} = `date`;
    chomp($ret{date});

    return %ret;
}
