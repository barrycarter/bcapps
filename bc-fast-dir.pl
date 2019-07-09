#!/bin/perl

# uses technique described at
# http://be-n.com/spw/you-can-list-a-million-files-in-a-directory-but-not-with-ls.html
# but in Perl

use Linux::Perl::getdents;
use FileHandle;
require "/usr/local/lib/bclib.pl";

my $fh = FileHandle->new("/home/barrycarter/");

debug("FH: $fh");

my @entities = Linux::Perl::getdents->getdents($fh, 10**6);

debug(var_dump("ENT", \@entities));


