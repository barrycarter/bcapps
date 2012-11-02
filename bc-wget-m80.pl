#!/bin/perl

# Another attempt to replicate "wget -m", but this time using Unix
# commands to speed things up. Efficiency IS an issue for this program.

# Files in this program may be very large, so no loading in memory. Files:

=item comments

Flowchart of sorts:

  - run curltodo.txt using parallel
  - add urlstodo.txt to urlsdone.txt
  - search files in curloutfiles.txt for hrefs, out to newhrefs.txt
  - find new URLs to download from newhrefs.txt (uniqify) to newhrefs2.txt
  - omit from new URLs ones we already have to urlstodo.txt
  - write curl commands to download urlstodo.txt to curltodo.txt
  - write curl output file (for urlstodo.txt) to curloutfiles.txt
  - loop

Files used:

urlsdone.txt: a sorted list of URLs already downloaded
urlstodo.txt: a sorted list of URLs to visit next

These unix commands dont require a subroutine (yet).

: merge urlstodo/done (after dling former)
sort -m urlstodo.txt urlsdone.txt > urlsdone.txt.new

: look through files in curloutfiles.txt for hrefs
parallel fgrep -i href < curloutfiles.txt

=cut

require "/usr/local/lib/bclib.pl";

unless (-d "f/f/f") {die "CWD must contain a/b/c for all hex abc";}

# url2curl("urls0.txt","curl0.txt");

hrefgrep2urls("hrefs0.txt","urls1.txt", "http://www.directionsforme.org");

=item url2curl($infile,$outfile)

Given $infile containing a sorted list of fully qualified URLs, write
$outfile, a list of curl commands to download these files to their
sha1 sums, using three level deep directories (eg, a/b/c/), and
$outfile.files, a list of the output files (for later use)

=cut

sub url2curl {
  my($infile,$outfile) = @_;
  local(*A);
  local(*B);
  open(A,$infile);
  open(B,">$outfile");
  while (<A>) {
    chomp;
    my($sha) = sha1_hex($_);
    # <h>this is NOT a reference to Eccentrica Gallumbits</h>
    $sha=~/^(.)(.)(.)/;
    print B "curl -o $1/$2/$3/$sha '$_'\n";
  }
  close(A);
  close(B);
  system("cut -d ' ' -f 3 $outfile > $outfile.files");
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
    /href="(.*?)"/;
    $_ = $1;

    # strip positionals + trailing slashes
    s/\#.*$//;
    s%/*$%%g;

    # for fully qualified URLs, only ones that match site
    if (m/^$site/) {
      # pass pure URLs
      print B "$_\n";
    } elsif (m%^/%) {
      # add site to / urls
      print B "$site$_\n";
    } else {
      # ignore all else (BAD!)
    }
  }

  close(A);
  close(B);

  # uniqify
  system("sort $outfile-1 | uniq > $outfile-2");

  # remove URLs weve already downloaded
  system("comm -23 $outfile-2 urlsdone.txt > $outfile");

}


