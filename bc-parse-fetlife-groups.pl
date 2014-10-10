#!/bin/perl

# Given the first pages of several fetlife groups, download all other
# pages (and, later, every message as well)

# TODO: individual posts may have multiple pages too...

require "/usr/local/lib/bclib.pl";

@order = ("gid", "members", "discussions", "comments", "name");
print join(" ",@order),"\n";

for $k (@ARGV) {
  my(%hash) = fetlife_groups(read_file($k));
  for $i (keys %hash) {
    for $j ("gid", "members", "discussions", "comments", "name") {
      print $hash{$i}{$j}," ";
    }
    print "\n";
  }
}

debug(unfold(\%hash));

# Given a string (normally read_file(something)), extract the list of
# fetlife groups (with group number and number of
# members/discussions/comments)

sub fetlife_groups {
  my($data) = @_;
  my(%hash);

  # ignore everything after end of group list + before "Most popular groups"
  $data=~s/<div class="pagination">.*$//s;
  $data=~s/^.*most popular groups//si;

  while ($data=~s%<li>(.*?)</li>%%s) {
    my($group) = $1;

    # group id (ignore if none)
    unless ($group=~s%"/groups/(\d+)"%%) {next;}
    my($gid) = $1;
    $hash{$gid}{gid} = $gid;

    # group name
    $group=~s%<span class="larger name_of_group mbn">(.*?)</span>%%;
    $hash{$gid}{name} = $1;

    # members/discussions/comments
    for $i ("members", "discussions", "comments") {
      $group=~s/([\d\,]+)\s+$i//s;
      my($num) = $1;
      $num=~s/,//;
      $hash{$gid}{$i} = $num;
    }
  }
  return %hash;
}


die "TESTING";

# rapid way to get page list
my($out,$err,$res) = cache_command2("fgrep page= *", "age=3600");

for $i (split(/\n/, $out)) {
  $i=~s/^(\d+):(.*)$//||warn("BAD LINE: $i");
  $data{$1} = $2;
}

# this file contains groups in most-to-least popular order
@groups = split(/\n/, read_file("groups.txt"));

for $i (@groups) {
  my($maxpage) = 0;
  while ($data{$i}=~s/page=(\d+)//) {
    if ($1>$maxpage) {$maxpage=$1;}
  }

  # URLs to dl all pages (no curl commands, since I need _fl_sessioid cookie)
  for $j (1..$maxpage) {
    print "'https://fetlife.com/groups/$i?page=$j'\n";
  }
}


