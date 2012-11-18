#!/bin/perl

# calls a Perl function from the command line
# TODO: add --help and --verbose options

require "/usr/local/lib/bclib.pl";

# TODO: add this to bclib.pl at some point
use Date::Manip;

$func=shift(@ARGV)||die("Usage: $0 ...");

# format: argument, file:filename (use contents as arugment), and - (use STDIN as argument)
for $i (@ARGV) {
    if ($i=~/^file:(.*)/) {
	push(@args,read_file($1));
    } elsif ($i eq "-") {
	push(@args,<STDIN>);
    } else {
	push(@args,$i);
    }
}

@res=&$func(@args);

print join(", ", @res),"\n";
