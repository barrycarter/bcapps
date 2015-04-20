#!/bin/perl

# Given a list of 1st pages of country/administrative area listings,
# create list of URLs to download data, with first pages of each area
# coming first. In other words, download "best" users for each area
# first.

# Input to this program is the pages that link to https://fetlife.com/places

require "/usr/local/lib/bclib.pl";

while (<>) {
  debug("GOT: $_");
}

