#!/bin/perl

# Parses a list of files, each containing a list of users (because
# filenames contain information per bc-dl-by-region.pl), parse data
# Sample file: https://fetlife.com/countries/233/kinksters?page=3

require "/usr/local/lib/bclib.pl";

my(%hash);

# order in which to print fields (also used for header)
my(@fields) = ("id", "screenname", "thumbnail", "age", "gender",
"role", "loc1", "loc2");

# TODO: make sure sorting doesn't break this field
print join(",",@fields),",page_number,scrape_time\n";

for $i (@ARGV) {

  # file name and mtime contains information
  unless ($i=~/page=(\d+)/) {warn "NO PAGE: $i";}
  my($page) = $1;
  my($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)=stat($i);
  my($time) = strftime("%Y-%m-%d %H:%M:%S", gmtime($mtime));
#  debug("TIME: $time");

  open(A,$i);

  while (<A>) {
    # new user marker
    if (s%href=\"/users/(\d+)\".*alt=\"(.*?)\".*src=\"(.*?)\"%%) {
      ($hash{id},$hash{screenname},$hash{thumbnail}) = ($1,$2,$3);
    } elsif (s%<span class="quiet">(.*?)</span>%%) {
      ($hash{age},$hash{gender},$hash{role}) = data2agr($1);
    } elsif (s%<em class="small">(.*?)</em>%%) {
      ($hash{loc1},$hash{loc2}) = loc2csc($1);
    } elsif (s%</div>%%) {
      # print user data and reset hash
      if (%hash) {
	my(@print) = @fields;
	map($_=$hash{$_},@print);
	# time and page
	push(@print,$time,$page);
	# TODO: kill spurious commas, if any
	print join(",",@print),"\n";
	%hash=();
      }
    } else {
#      debug("IGNRING: $_");
    }
  }
}

# parses data into age, gender, role

sub data2agr {
  if ($_[0]=~m%(\d+)([A-Z/]*)\s*(.*)$%) {return ($1,$2,$3);}
  warn ("BAD DATA: $_[0]");
}

sub loc2csc {
  my($loc) = @_;

  # special cases
  $loc=~s/NoMa, Washington, D\.C\., District of Columbia/NoMa Washington D.C., District of Columbia/;
  $loc=~s/, Arkansas, Arkansas/, Arkansas/;
  # intentionally no space between comma and Nebraska below
  $loc=~s/,Nebraska, Nebraska/, Nebraska/;
  $loc=~s/, Missouri\/Kickapoo, Missouri/, Missouri/;

  if ($loc=~s/, (city of|the|Republic of),/,/is || $loc=~s/, (Republic of|Islamic Republic of|United Republic of|the Former Yugoslav Republic of|Federated States of|the Democratic Republic of the|Democratic People&\#x27\;s Republic of)$//) {
#    debug("NEWLOC: $loc");
  }

  # useless (if condition for testing only for now)
#  if ($loc=~s/, (city of|the|republic of|islamic republic of|united republic of)(,|$)/,/is) {
#    debug("NEWLOC: $loc");
#  }

  my(@data)=split(/\,\s*/, $loc);

  if (scalar(@data)==1) {return ("",$data[0]);}
  if (scalar(@data)==2) {return (@data);}
  warn("NOPARSE: $loc");
}
