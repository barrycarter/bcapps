#!/bin/perl

# Parses a user list, ie: https://fetlife.com/countries/233/kinksters?page=3

require "/usr/local/lib/bclib.pl";

my(%hash);
while (<>) {
  # new user marker
  if (s%href=\"/users/(\d+)\".*alt=\"(.*?)\".*src=\"(.*?)\"%%) {
    ($hash{num},$hash{id},$hash{img}) = ($1,$2,$3);
  } elsif (s%<span class="quiet">(.*?)</span>%%) {
    ($hash{age},$hash{gender},$hash{role}) = data2agr($1);
#    debug("ROLE: $1");
  } elsif (s%<em class="small">(.*?)</em>%%) {
    loc2csc($1);
#    $hash{location} = $1;
  } elsif (s%</div>%%) {
    # print user data and reset hash
    if (%hash) {
      print "$hash{num}|$hash{id}|$hash{img}|$hash{age}|$hash{gender}|$hash{role}|$hash{location}\n";
      %hash=();
    }
  } else {
#    debug("IGNRING: $_");
  }
}

# parses data into age, gender, role

sub data2agr {
  if ($_[0]=~m%(\d+)([A-Z/]*)\s*(.*)$%) {return ($1,$2,$3);}
  warn ("BAD DATA: $_[0]");
}

sub loc2csc {
  my($loc) = @_;

  my(@data)=split(/\,\s*/, $loc);

  # just country
  if (scalar(@data)==1) {return ("","",$data[0]);}
  # country and city (I think?)
  if (scalar(@data)==2) {return ($data[0],"",$data[1]);}
  # country/city/state
  if (scalar(@data)==3) {return ($data[0],$data[1],$data[2]);}
  warn("NOPARSE: $loc");
}
