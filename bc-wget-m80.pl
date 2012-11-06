#!/bin/perl

# Another attempt to replicate "wget -m", but this time using Unix
# commands to speed things up. Efficiency IS an issue for this program.

# Files in this program may be very large, so no loading in memory. Files:

# if restarting, rm urlsdone*.txt mapping.txt

require "/usr/local/lib/bclib.pl";

# for this download
$site = "http://www.directionsforme.org";

# number of jobs parallel should run at once
$parjobs = 10;

unless (-d "f/f/f") {die "CWD must contain a/b/c for all hex abc";}

# this file must exist for sort -m to work
system("touch urlsdone.txt");

# write curl commands to download urlstodo.txt to curltodo.txt
# write curl output files (for urlstodo.txt) to curloutfiles.txt
url2curl("urlstodo.txt","curltodo.txt","curloutfiles.txt");

# run curltodo.txt using bc-parallel (this is the only one where sockets are important; for the rest continue to use regular parallel)
system("bc-parallel.pl -j $parjobs < curltodo.txt");

# add urlstodo.txt to urlsdone.txt
system("sort -um urlstodo.txt urlsdone.txt > urlsdone.txt.new");
system("mv urlsdone.txt urlsdone.txt.old; mv urlsdone.txt.new urlsdone.txt");

# search files in curloutfiles.txt for hrefs, out to newhrefs.txt
system("parallel -j $parjobs fgrep -i href < curloutfiles.txt > newhrefs.txt");

# find new URLs to download from newhrefs.txt (uniqify) to newhrefs2.txt
# omit from new URLs ones we already have to urlstodo.txt
hrefgrep2urls("newhrefs.txt","newhrefs2.txt",$site);

system("mv urlstodo.txt urlstodo.txt.old; mv newhrefs2.txt urlstodo.txt");

# url2curl("urls0.txt","curl0.txt");
# hrefgrep2urls("hrefs0.txt","urls1.txt", "http://www.directionsforme.org");

=item comments

Flowchart of sorts:

  - write curl commands to download urlstodo.txt to curltodo.txt 
  - write curl output files (for urlstodo.txt) to curloutfiles.txt
  - run curltodo.txt using parallel
  - add urlstodo.txt to urlsdone.txt
  - search files in curloutfiles.txt for hrefs, out to newhrefs.txt
  - find new URLs to download from newhrefs.txt (uniqify) to newhrefs2.txt
  - omit from new URLs ones we already have to urlstodo.txt
  - loop

Files used:

urlsdone.txt: a sorted list of URLs already downloaded
urlstodo.txt: a sorted list of URLs to visit next
mapping.txt: file location of URLs downloaded

These unix commands dont require a subroutine (yet).

: merge urlstodo/done (after dling former)
sort -m urlstodo.txt urlsdone.txt > urlsdone.txt.new

: look through files in curloutfiles.txt for hrefs
parallel fgrep -i href < curloutfiles.txt

=cut

=item url2curl($infile,$outfile1,$outfile2)

Given $infile containing a sorted list of fully qualified URLs, write
$outfile1, a list of curl commands to download these files to their
sha1 sums, using three level deep directories (eg, a/b/c/), and
$outfile2, a list of the output files (for later use)

=cut

sub url2curl {
  my($infile,$outfile1,$outfile2) = @_;
  local(*A);
  local(*B);
  local(*C);
  open(A,$infile);
  open(B,">$outfile1");
  open(C,">$outfile2");
  open(D,">>mapping.txt");
  while (<A>) {
    chomp;
    my($sha) = sha1_hex($_);
    # <h>this is NOT a reference to Eccentrica Gallumbits</h>
    $sha=~/^(.)(.)(.)/;
    my($fname) = "$1/$2/$3/$sha";

    # TODO: this test is expensive and for testing only!
    if (-f $fname) {
      # do nothing if already have it
#      print B ": curl -sLo $fname '$_'\n";
    } else {
      print B "curl -sLo $fname '$_'\n";
    }
    # however, always print out file and mapping
    print C "$fname\n";
    print D "$fname $_\n";
  }
  close(A);
  close(B);
  close(C);
  close(D);
}

=item hrefgrep2urls($infile,$outfile,$site)

Given $infile containing the output of 'fgrep -i href [files]', write
$outfile, a list of unique fully qualified URLs assuming $site for
relative URLs.

TODO: DOES NOT HANDLE URLS LIKE "foo", only "/foo"

=cut

sub hrefgrep2urls {
  my($infile,$outfile,$site) = @_;
  local(*A);
  local(*B);
  open(A,$infile);
  open(B,">$outfile-1");
  while (<A>) {
    chomp;

    # find URL (TODO: assumes well-formed)
    while (s/href="(.*?)"//) {
      my($i) = $1;

      # strip positionals + trailing slashes
      $i=~s/\#.*$//;
      $i=~s%/*$%%g;

      # for fully qualified URLs, only ones that match site
      if ($i=~m/^$site/) {
	# pass pure URLs
	print B "$i\n";
      } elsif ($i=~m%^/%) {
	# add site to / urls
	print B "$site$i\n";
      } else {
	# ignore all else (BAD!)
      }
    }
  }

  close(A);
  close(B);

  # uniqify
  system("sort -u $outfile-1 > $outfile-2");

  # remove URLs weve already downloaded
  system("comm -23 $outfile-2 urlsdone.txt > $outfile");

}


