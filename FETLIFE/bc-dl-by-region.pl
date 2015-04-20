#!/bin/perl

# Given a list of 1st pages of country/administrative area listings,
# create list of URLs to download data, with first pages of each area
# coming first. In other words, download "best" users for each area
# first.

# Input to this program is the pages that link to https://fetlife.com/places

require "/usr/local/lib/bclib.pl";

while (<>) {
#  debug("THUNK: $_");
  if (m%>(.*?) Kinksters living in (.*?)<%) {
    debug("GOT: $1 $2");
  }

  if (m%<a href=\"(.*?)/kinksters\">view more%) {
    debug("GOT: $1");
  }

#  debug("GOT: $_");
}

