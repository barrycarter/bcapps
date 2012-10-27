#!/bin/perl

# Parses data from directions4me.org

require "/usr/local/lib/bclib.pl";

# TODO: as the name suggests, this is just a temporary list for testing
open(A,"/mnt/sshfs/D4M2/temp.somefiles.rand");

while (<A>) {
  # correct to full path
  s%^\./%/mnt/sshfs/D4M2/%;
  debug("FILE: $_");
  $all = read_file($_);

  my(%hash) = ();

  # product name
  $all=~s%<title>(.*?)</title>%%;
  $hash{Name} = $1;
  $hash{Name}=~s/\s*\-\s*Directions for me//i;

  # special case for data delimited using <strong>
  while ($all=~s%<strong>(.*?):?</strong>(.*?)<%%is) {
    ($key,$val) = ($1,$2);
    # ignore empties and numericals
    if ($key=~/^\d*$/) {next;}
    $hash{$key} = trim($val);
  }

  # special cases for manufacturer
  $all=~s%<h3>Manufacturer</h3>\s*(.*?)<%%;
  $hash{Manufacturer} = $1;

  # and UPC
  $all=~s%<h3>UPC</h3>\s*<p>(.*?)</p>%%;
  $hash{UPC} = $1;

  # go through table rows and cells
  while ($all=~s%<tr.*?>(.*?)</tr>%%is) {
    $row = $1;

    # ignore empty (not working, may contain empty <td>s
#    if ($row=~/^\s*$/s) {next;}

    @arr = ();
    while ($row=~s%<td.*?>(.*?)</td>%%s) {
      # cleanup cell + push to row-specific array
      $cell = $1;
      $cell = trim($cell);
      push(@arr, $cell);
    }

    # hash for this row (assuming it has a header)
    $hash{$arr[0]} = coalesce([@arr[1..$#arr]]);
  }

  # only stuff that has calories
  unless ($hash{Calories}) {next;}

  push(@hashes, \%hash);

  if (++$n > 100) {
    warn "TESTING";
    last;
  }
}

debug(hashlist2sqlite(\@hashes, "foods"));


