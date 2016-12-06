#!/bin/perl

# converts the list of packages I want (and, later, that CentOS 7 can
# actually install) into a giant "yum" command and writes it to
# yum-runme.sh

require "/usr/local/lib/bclib.pl";

open(A,"egrep -v '^\$|^#' pkglist.txt|");

while (<A>) {chomp; $pkg{$_}=1;}

write_file("yum -y install ".join(" ",sort keys %pkg)."\n", "yum-runme.sh");

