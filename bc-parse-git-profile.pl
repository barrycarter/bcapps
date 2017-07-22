#!/bin/perl

# Trivial script to parse GitHub user profiles

require "/usr/local/lib/bclib.pl";

my($all) = cmdfile();


# username and name
$all=~s%<title>(.*?)</title>%%;
my($names) = $1;
$names=~s/^\s*(.*?)\s*\((.*?)\)//;
my($user, $name) = ($1, $2);

# TODO: this could be done more efficiently, since these are similar

$all=~s%<span class="p-org"><div>(.*?)</div></span>%%;
# TODO: will this inherit $1 above if I don't reset?
my($org) = $1;

$all=~s%<span class="p-label"><div>(.*?)</div></span>%%;
my($loc) = $1;

$all=~s%<a href="(.*?)" class="u-url"%%;
my($url) = $1;

# TODO: github doesnt close this quote properly!
$all=~s%\"mailto:(.*?)</a>%%;
my($email) = $1;

# convert to usable form
$email=~s/\&\#x(.*?)\;/chr(hex($1))/eg;

debug("EM: $email");



