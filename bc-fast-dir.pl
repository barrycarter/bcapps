#!/bin/perl

# uses technique described at
# http://be-n.com/spw/you-can-list-a-million-files-in-a-directory-but-not-with-ls.html
# but in Perl


# The return is a list of hash references; each hash contains the keys
# ino, off, type, and name. These correspond with the relevant parts
# of struct linux_dirent64 (cf. man 2 getdents).

use Linux::Perl::getdents;
use FileHandle;
require "/usr/local/lib/bclib.pl";

my $fh = FileHandle->new("/home/barrycarter/Downloads/");

debug("FH: $fh");

my @entities = Linux::Perl::getdents->getdents($fh, 10**6);

debug(var_dump("ENT", \@entities));

debug("NUM: $#entities+1");


