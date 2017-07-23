#!/bin/perl

# Trivial script to parse GitHub user profiles

require "/usr/local/lib/bclib.pl";

my($all) = cmdfile();


# username and name
$all=~s%<title>(.*?)</title>%%;
my($names) = $1;

my($user, $name);
if ($names=~s/^\s*(.*?)\s*\((.*?)\)//) {
  ($user, $name) = ($1, $2);
} else {
  ($user, $name) = ($1, "");
}

# TODO: this could be done more efficiently, since these are similar

# <h>use of ternary operator here is hideous but cute</h>
my($org) = $all=~s%<span class="p-org"><div>(.*?)</div></span>%%?$1:"";
my($loc) = $all=~s%<span class="p-label">(.*?)</span>%%?$1:"";
my($url) = $all=~s%<a href="(.*?)" class="u-url"%%?$1:"";
my($email) = $all=~s%"mailto:(.*?)"%%?$1:"";

# remove html from org, if any
$org=~s/<.*?>//g;

# convert to usable form
$email=~s/\&\#x(.*?)\;/chr(hex($1))/eg;

print qq%"$user","$name","$org","$loc","$url","$email"\n%;
