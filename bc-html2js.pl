#!/bin/perl

# TODO: this doesn't work w/ remote URLs (but could)

# Given an HTML file with SCRIPT tags, turn it into pure JS by
# hard-loading script srcs, removing HTML-- really only useful to me

require "/usr/local/lib/bclib.pl";

my($data, $fname) = cmdfile();

# load stuff

# TODO: could replace readfile here with something more generic in
# case I do want to load URLs in the future

$data=~s%<script src="(.*?)"></script>%read_file($1)%iseg;
$data=~s%<script>(.*?)</script>%$1%isg;

# TODO: this does NOT get rid of html tags

print $data;

