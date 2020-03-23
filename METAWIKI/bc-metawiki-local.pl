#!/bin/perl

# Create HTML (and perhaps text?) pages from a "meta media wiki
# definition file" (pbs.txt); this is sort of specific for files that
# have date followed by data or "MULTIREF" followed by data

# TODO: create captions of actual images for feh

# To test against the db bc-pbs3.pl creates, see ~/20200317 (LAPAZ)

# sqlite3 -batch /var/tmp/pbs3.db "SELECT source,relation,target FROM
# triples WHERE relation NOT IN ('hash', 'prev', next');" | sort >
# old-db-sorted.txt

# TODO: don't rely on ("date info") or ("MULTIREF info") in source file

# TODO: add next, prev, class, and hash triples

require "/usr/local/lib/bclib.pl";

my($data, $fname) = cmdfile();

# to store all triples
my(%triples);

# to store whether properties are literal or object to object
my(%props);

# read the data and limit to the <data></data> section

$data=~m%<data>(.*?)</data>%s;
$data = $1;

# debug("DATA IS: $data");
    
# special hack for {{wp|foo}} only

# TODO: redo this if needed
$data=~s/\{\{(.*?)\|(.*?)\}\}/[[$1::-class::$2]]/sg;

# debug("POST: $data");

# TODO: this is just temporary to match old db

# $data=~s/\{\{(.*?)\|(.*?)\}\}/$2/sg;

# replace apostrophes with their HTML equivalent

# $data=~s/\'/&\#39\;/g;

# my(@data) = expand_dates($data);
my(@data) = split(/\n/, $data);

# debug("DATA", @data);

create_semantic_triples(@data);

for $i (sort keys %triples) {
    for $j (sort keys %{$triples{$i}}) {
	for $k (sort keys %{$triples{$i}{$j}}) {
	    debug("$i/$j/$k");
	}
    }
}


# Given data where the first field of each line represents date(s),
# return array of lines where each line has a single date

sub expand_dates {

    my($data) = @_;

    my(@ret);

    for $i (split(/\n/, $data)) {

	# skip blank lines
	if ($i=~/^\s*$/) {next;}
	
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

#	debug("I: $i");

	# replace commas w HTML equivalent
#	$i=~s/,/&\#44\;/g;

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

    debug("PARSE_TRIPLE($source, $string)");
    my($linktext);

    my($x, $y, $z, $t);
    my(@x, @y, @z);

    # if double double colons

    if ($string=~s/^(.*?)::(.*?):(:|\=)(.*?)$//) {
	($x, $y, $t, $z) = ($1, $2, $3, $4);
	@x = split(/\+/, $x);
    } elsif ($string=~s/^(.*?):(:|\=)(.*?)$//) {
	($x, $y, $t, $z) = ($source, $1, $2, $3);
	@x = parse_date_list($x);
    } else {
	return "LINK($string)";
    }

    # as lists if they have + signs in them
    my(@y) = split(/\+/, $y);
    my(@z) = split(/\+/, $z);

    if ($t eq ":") {
	for $i (@x) {
	    for $j (@y) {
		for $k (@z) {
		    $k=~s/LINK\((.*?)\)/$1/g;
		    $triples{$i}{$j}{$k} = 1;
		    $triples{$k}{"-$j"}{$i} = 1;
		}
	    }
	}
	return "LINK($z)";
    }


    if ($t eq "=") {
	for $i (@x) {
	    for $j (@y) {
		for $k (@z) {
		    $triples{$i}{$j}{$k} = 1;
		}
	    }
	}
	return $z;
    }
}
