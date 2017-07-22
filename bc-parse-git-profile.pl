#!/bin/perl

# Trivial script to parse GitHub user profiles

require "/usr/local/lib/bclib.pl";

my($all) = cmdfile();


# username and name
$all=~s%<title>(.*?)</title>%%;
my($names) = $1;
$names=~s/^\s*(.*?)\s*\((.*?)\)//;
my($user, $name) = ($1, $2);

debug("$user/$name");

