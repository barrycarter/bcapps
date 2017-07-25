#!/bin/perl

# Since fetlife.com no longer lets me link directly to images (and
# may've changed their image scheme overall), I need to find local
# copies of thumbnails to link in db; unfortunately, the local copies
# I have are different from those referenced in the db-- this attempts
# to reconcile the two

require "/usr/local/lib/bclib.pl";


# NOTE: this is the ugly way to find missing images-- a better way is
# to use sort and comm

my(%have, %canon);

# confirmed separately that all _200.jpg files also have _60.jpg
# equivalents (except one which I need to handle special case)

# TODO: handle special case

# TODO: consider using 200px thumbnails where possible

open(A,"bzcat fl-thumbs-on-bcinfo3.txt.bz2|egrep '_60.jpg\$'|");

while (<A>) {
  chomp;

  # record that we have this image
  $have{$_}=1;

  # find uid and make image canonical for that uid (unless image in db
  # already exists)
  my(@list) = split(/\//, $_);
  $canon{$list[2]} = $_;
}

close(A);

# now, find images referenced by db that dont actually exist

open(A,"bzcat fl-thumbs-ref-by-db.bz2|");

print "START TRANSACTION;\n";


while (<A>) {
  chomp;

  # if we already have this image, ignore this uid
  if ($have{$_}) {next;}

  # since the image is missing, use canon image instead
  my(@list) = split(/\//, $_);
  unless ($canon{$list[2]}) {next;}

  # TODO: this removes the https from specific users while leaving it
  # for others, which is ugly

  print "UPDATE kinksters SET thumbnail='$canon{$list[2]}' WHERE id=$list[2];\n";

}

print "COMMIT;\n";

close(A);



