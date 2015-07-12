#!/bin/perl

# command that is called to create a dink screen from modified dinkvar.c

require "/usr/local/lib/bclib.pl";

my($screen,$path) = @ARGV;

xmessage("I have been called: $screen and $path");


