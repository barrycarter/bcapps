#!/bin/perl

require "/usr/local/lib/bclib.pl";

print "Access-Control-Allow-Origin: *\n";

# TODO: restore to application/json
# print "Content-type: application/json\n\n";

print "Content-type: text/plain\n\n";

# NOTE: for testing, setenv QUERY_STRING ...

# get the query string

my(%query) = str2hash($ENV{QUERY_STRING});

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

debug({&$f});

$result{output} = {&$f};

# $result{output} = \&$f();

print JSON::to_json(\%result),"\n";

die "TESTING";

my($func) = "bcapi_$result{input}{f}";

debug($func);

die "TESTING";


# TODO: the work

$result{output} = bcapi_time(%query);

# print w/ new line

print JSON::to_json(\%result),"\n";

# TODO: functions can use global variable for convenience



if ($query{f} eq "time") {
    $result{input} = \%query;
    $result{output} = bcapi_time(%query);
    print JSON::to_json(\%result),"\n";
#    print JSON::to_json(bcapi_time(%query));
}

if ($query{f} eq "terminator") {
    $result{input} = \%query;
    $result{output} = bcapi_terminator(%query);
    print JSON::to_json(\%result),"\n";
}


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

# print "Hello Bob\n";

# bcapi_time(%query);

# print JSON::to_json(\%query);

# for $i (sort keys %query) {
#    print "$i: $query{$i}\n";
# }

# TODO: properly document this

# gives time in a given timezone
# tz = time zone

sub bcapi_time {

    my(%hash) = @_;
    my(%ret);

    if ($hash{tz}=~s/[^a-z0-9\/]//isg) {
	$ret{error} .= "Invalid characters in your timezone were removed";
    }

    $ENV{TZ} = $hash{tz};

    $ret{date} = `date`;
    chomp($ret{date});

    return %ret;
}

# this is a local version of cache_command that lets me run commands
# on terramapdaventure.com via ssh while testing

sub cache_command_local {

    my($cmd, $options);

}
