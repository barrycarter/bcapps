#!/bin/perl

# Given a list of MD5 sums in Mac OS X format:
# MD5 (filename) = (hash)
# confirm present each set of equal files but delete nothing
# this is just an aid to the end user, doesn't actually do anything

# --canononly: only show files whose hashes match that of a canon file

require "/usr/local/lib/bclib.pl";

# canon regexps; files meeting these regexps are never deleted, though
# other (non-canon) files with the same md5/sha1 should be deleted
@canon = split(/\n/, read_file("/home/barrycarter/20150215/canonregs.txt"));

my(%count,%files,$count,%canon);

while (<>) {
  chomp;

  # modification for sha1 (Unix form) below
#  unless (/^MD5 \((.*)\) = ([0-9a-f]{32})$/) {warn("BAD LINE: $_"); next;}
#  my($file, $md5) = ($1,$2);

  unless (/^([0-9a-f]{40})\s+(.*)$/) {warn("BAD LINE: $_"); next;}
  my($file, $md5) = ($2, $1);

  # confirm file existence
  unless (-f $file) {debug("NO SUCH FILE: *$file*"); next;}

  # note it as a list of files for this hash, and number hash to
  # present in order
  $files{$md5}{$file} = 1;
  unless ($count{$md5}) {$count{$md5} = ++$count;}

  # this is ugly
  for $i (@canon) {
    if (index($file,$i)>-1) {
      # note this hash has at least one canon file
      $canon{$md5}{$file}=1;
      last;
    }
  }
}

# only canon hashes

if ($globopts{canononly}) {
  for $i (keys %canon) {
    # list all non-canon files
    my(@keys) = keys %{$files{$i}};
    if ($#keys==0) {next;}

    debug("CANON:", keys %{$canon{$i}});

    # show only non canon files
    for $j (@keys) {
      if ($canon{$i}{$j}) {next;}
      print qq%"$j"\n%;
    }
  }
} else {
  for $i (sort {$count{$a} <=> $count{$b}} keys %count) {
    # if only one existing file for this hash, do nothing; else print
    @keys = keys %{$files{$i}};
    if ($#keys==0) {next;}

    print "FILES FOR $i:\n\n";
    # putting files in quotes makes it easier to delete them
    for $j (@keys) {print qq%"$j"\n%;}
  print "\n"x3;
  }
}
