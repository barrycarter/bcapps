#!/bin/perl

# Parses data from directions4me.org

require "/usr/local/lib/bclib.pl";

# TODO: as the name suggests, this is just a temporary list for testing
# these are lines from mapping.txt
open(A,"/mnt/sshfs/D4M4/temp.somefiles.rand");

while (<A>) {

  # only need filename not target URL
  s/\s+.*$//isg;

  # correct to full path
  s%^%/mnt/sshfs/D4M4/%;

  # mapping.txt contains mappings for files that don't exist (yet); skip those
  unless (-f $_) {
#    debug("NOEXIST: $_");
    next;
  }

  $all = read_file($_);

  # ignore files sans calories (case-sensitive)
  unless ($all=~/Calories/) {
#    debug("NOTFOOD: $_");
    next;
  }

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
    $key=~s/[^a-z]//isg;
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
      $cell =~s/[^a-z]//isg;
      push(@arr, $cell);
    }

    # hash for this row (assuming it has a header)
    $hash{$arr[0]} = coalesce([@arr[1..$#arr]]);
  }

  # only stuff that has calories
  unless ($hash{Calories}) {next;}

  # silly to wrap single hash in list, but I didnt want to write new function
  $l[0] = \%hash;
  debug("0: $l[0]");

  # this gets large, so print on a row by row basis
  @query = hashlist2sqlite(\@l,"foods");

 debug("QUERY:", @query);

  # debug(hashlist2sqlite(\@hashes, "foods"));
  # push(@hashes, \%hash);


}

