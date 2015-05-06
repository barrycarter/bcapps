#!/bin/perl

# Given a list of MD5 sums in Mac OS X format:
# MD5 (filename) = (hash)
# confirm present each set of equal files but delete nothing
# this is just an aid to the end user, doesn't actually do anything

# --canononly: only show files whose hashes match that of a canon file

require "/usr/local/lib/bclib.pl";

# canon regexps; files meeting these regexps are never deleted, though
# other (non-canon) files with the same md5/sha1 should be deleted
# @canon = split(/\n/, read_file("/home/barrycarter/20150215/canonregs.txt"));

my(%count,%files,$count,%canon);

while (<>) {
  chomp;

  if ($n++%100==0) {debug("READING: $_");}

  # accepts Mac MD5 and Unix sha1 (but not vice versa for the moment)

  my($file,$hash);

  if (/^MD5 \((.*)\) = ([0-9a-f]{32})$/) {
    ($file, $hash) = ($1,$2);
  } elsif (/^([0-9a-f]{40})\s+(.*)$/) {
    ($file, $hash) = ($2, $1);
  } else {
    warn("BAD LINE: $_");
    next;
  }


  # confirm file existence
  unless (-f $file) {debug("NO SUCH FILE: *$file*"); next;}

  # note it as a list of files for this hash, and number hash to
  # present in order
  $files{$hash}{$file} = 1;
  unless ($count{$hash}) {$count{$hash} = ++$count;}

  # this is ugly

  if ($globopts{canononly}) {
    for $i (@canon) {
      if (index($file,$i)>-1) {
	# note this hash has at least one canon file
	$canon{$hash}{$file}=1;
	last;
      }
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
    @keys = sort keys %{$files{$i}};
    if ($#keys==0) {next;}

    # suggest removal of all but first
    print "FILES FOR $i:\n\n";
    # putting files in quotes makes it easier to delete them
    for $j (@keys) {print qq%"$j"\n%;}
    print "\n"x3;

    for $j (@keys[1..$#keys]) {
      # TODO: make this an option, don't always print
      print "rm \"$j\"\n";
    }
  }
}
