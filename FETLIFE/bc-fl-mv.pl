#!/bin/perl

# renames fetlife regionsuck files to match fetlife path (better for
# google to crawl that way)

require "/usr/local/lib/bclib.pl";

my(%hash)=("co" => "countries", "aa" => "administrative_areas");

for $i (@ARGV) {

  # separate into dir and base
  $i=~m%^(.*)/(.*?)$%;
  my($dir,$file) = ($1,$2);

  # convert basename
  unless ($file=~/fetlife-(co|aa)-0*(\d+)\-p0*(\d+)\./) {warn "BAD: $i";next;}
  my($newdir,$newfile) = ("$hash{$1}/$2","kinksters?page=$3");

  # this makes the directories early, but I am probably ok with that
  unless (-d $newdir) {system("mkdir -p $newdir");}

  print "mv $i '$newdir/$newfile'\n";
}


