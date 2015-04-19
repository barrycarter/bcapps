#!/bin/perl

# Parses a user list, ie: https://fetlife.com/countries/233/kinksters?page=3

require "/usr/local/lib/bclib.pl";

my(%hash);
while (<>) {
  # new user marker
  if (s%href=\"/users/(\d+)\".*alt=\"(.*?)\".*src=\"(.*?)\"%%) {
    ($hash{num},$hash{id},$hash{img}) = ($1,$2,$3);
  } elsif (s%<span class="quiet">(.*?)</span>%%) {
    $hash{role} = $1;
  } elsif (s%<em class="small">(.*?)</em>%%) {
    $hash{location} = $1;
  } elsif (s%</div>%%) {
    # print user data and reset hash
    if (%hash) {
      print "$hash{num}|$hash{id}|$hash{img}|$hash{role}|$hash{location}\n";
      %hash=();
    }
  } else {
#    debug("IGNRING: $_");
  }
}

