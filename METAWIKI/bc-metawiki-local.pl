#!/bin/perl

# Create HTML (and perhaps text?) pages from a "meta media wiki
# definition file" (pbs.txt); this is sort of specific for files that
# have date followed by data or "MULTIREF" followed by data

# TODO: create captions of actual images for feh

# TODO: don't rely on ("date info") or ("MULTIREF info") in source file

require "/usr/local/lib/bclib.pl";

my($data, $fname) = cmdfile();

# to store all triples
my(%triples);

# read the data and limit to the <data></data> section

$data=~m%<data>(.*?)</data>%s;
$data = $1;
    
# special hack for {{wp|foo}} only

$data=~s/\{\{(.*?)\|(.*?)\}\}/LINK($1,$2,SPEC)/sg;

my(@data) = expand_dates($data);

# debug("DATA", @data);

create_semantic_triples(@data);

for $i (sort keys %triples) {
    for $j (sort keys %{$triples{$i}}) {
	for $k (sort keys %{$triples{$i}{$j}}) {
	    debug("$i|$j|$k");
	}
    }
}


# Given data where the first field of each line represents date(s),
# return array of lines where each line has a single date

sub expand_dates {

    my($data) = @_;
    my(@ret);

    for $i (split(/\n/, $data)) {
	
	$i=~s/^(\S+)\s+//;
	my(@dates) = parse_date_list($1);
	for $j (@dates) {
	    push(@ret, "$j $i");
	}
    }

    return @ret;
}

# given a list of lines that represent source and data, create
# semantic triples and return resolved value after line interpolation

sub create_semantic_triples {

    my(@data) = @_;

    # go through each line of data
    for $i (@data) {

	# find leftmost word (which is always a single date)
	$i=~s/^(\S+)\s+//;
	my($date) = $1;

	# TODO: don't ignore MULTIREF
	if ($date eq "MULTIREF") {
	    # TODO: don't ignore silently
#	    warn("IGNORING MULTIREF");
	    next;
	}

	# keep parsing until no double brackets are left (nothing in while loop)
	while ($i=~s/\[\[([^\[\]]*?)\]\]/parse_triple($date,$1)/e) {}
    }
}

=item parse_triple($source, $string)

Given a $source of data (like "2020-03-17") and a string like
"[[x::y]]" (with several variants), add to global list of semantic
triples and return a string. This function is called "inside out", so
$string will never have double brackets

Plus signs like [[x+y::...]] are treated like [[x::...]], [[y::...]]
and add to global list of triples and returns (TODO: what to return)

Details:

[[x]] - return LINK(x)

[[x::y]] - add $triples{$source}{x}{y} and $triples{y}{"-x"}{$source} and
return string LINK(y)

[[x::y|z]] - add $triples{$source}{x}{y} and $triples{y}{"-x"}{$source} and
return string LINK(y,z)

[[x::y::z]] - adds $triples{x}{y}{z} and $triples{z}{"-y"}{x} and
returns LINK(z)

TODO: this currently adds to GLOBAL hash

=cut

sub parse_triple {

    my($source, $string) = @_;

    # x y and z as above
    my($x, $y, $z) = split(/::/, $string);

    # as lists if they have + signs in them
    my(@x) = split(/\+/, $x);
    my(@y) = split(/\+/, $y);
    my(@z) = split(/\+/, $z);

    # if just one part, return comma delimited values
    if ($#parts == 0) {

	map($_="LINK($_)", @x);

	return join(", ", @x);
    }

    if ($#parts == 1) {

	my($linktext);

	if ($parts[1]=~s/\|(.*)//) {$linktext=$1;}

	for $i (@sources) {

	    # list of parts[0] (can have multiples)
	    

	    $triples{$i}{$parts[0]}{$parts[1]} = 1;
	    $triples{$parts[1]}{"-$parts[0]"}{$i} = 1;
	}

	if ($linktext) {return "LINK($parts[1],$linktext";}
	return "LINK($parts[1])";
    }

    if ($#parts == 2) {

	$triples{$parts[0]}{$parts[1]}{$parts[2]} = 1;
	$triples{$parts[2]}{"-$parts[1]"}{$parts[0]} = 1;
	return "LINK($parts[2])";
    }

    warn("MORE THAN TWO SETS OF COLONS: $source, $string");
}
