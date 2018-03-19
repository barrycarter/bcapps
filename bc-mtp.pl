#!/bin/perl

# uses MTP commands to sync my phone to ~/MYPHONE <h>(original name, huh?)</h>

require "/usr/local/lib/bclib.pl";

my($out, $err, $res);

warn "only pulling some file types for now";

# TODO: if this returns "false", abort prog
($out, $err, $res) = cache_command2("sudo mtp-detect", "age=3600");

# cache results for one hour, just in case of connection issues
($out, $err, $res) = cache_command2("sudo mtp-files", "age=3600");

# just to examine them for now
write_file($out, "/tmp/mtp-files.txt");

# pretty sure at least two of these are redundant, but, for now...
($out, $err, $res) = cache_command2("sudo mtp-folders", "age=3600");

write_file($out, "/tmp/mtp-folders.txt");

# pull dir structure
($out, $err, $res) = cache_command2("sudo mtp-filetree", "age=3600");

write_file($out, "/tmp/mtp-filetree.txt");

# it turns out mtp-filetree.txt is the only one I need, but the others
# provide useful info

# debug("OUT: $out");

my(@parents);

for $i (split(/\n/, $out)) {

  # delete spaces, but count them first (2 spaces = one depth level), find name

  $i=~m/^(\s*)(\d+)\s+(.*)$/;
  my($depth, $id, $name) = (length($1)/2, $2, $3);

#  debug("D: $depth, I: $id, N: $name");

  # compare depth level to list of parents dirs

  # if depth is greater, push new parent and do nothing else
  if ($depth > $#parents) {push(@parents, $name); next;}

  # if depth is less, pop off last parent, but continue
  if ($depth < $#parents) {pop(@parents);}

  debug("I: $i, PARENTS ($#parents):",@parents);

  # all other cases, dir level remains the same, do nothing
  # print name in all cases

#  print join("/", @parents),"/$name\n";

}


die "TESTING";

my(@files) = split(/^File ID: /m, $out);

for $i (@files) {

  # the file ID

  $i=~s/^\s*(\d+)\s*//;
  my($id) = $1;

  # TODO: want to avoid blank id and assuming id=0 is bad

  unless ($id) {next;}

  # assuming IDs are unique, they may not be

  if ($hash{$id}{seen}) {die("REPEAT ID: $id");}
  $hash{$id}{seen} = 1;

  # set hash 
  while ($i=~s/^\s*(.*?):\s+(.*)$//m) {$hash{$id}{lc($1)} = $2;}

  # file size line doesn't have a colon (sigh)
  $i=~s/^\s*File\s*size\s*(\d+)//m;

  $hash{$id}{filesize} = $1;

  # just pulling jpegs and dbs for now
  unless ($hash{$id}{filename}=~/\.(jpg|db)$/) {next;}

  print join("\t", $id, $hash{$id}{filename}, $hash{$id}{filesize}),"\n";

  debug("HASH($id) IS:", %{$hash{$id}});

}

=item comment

format of mtp-files output:

File ID: 1077
   Filename: 20180316_122521.jpg
   File size 3315654 (0x00000000003297C6) bytes
   Parent ID: 1075
   Storage ID: 0x00010001
   Filetype: JPEG file

format of mtp-folders output:

1075      Camera

format of mtp-filetree output:

  102083 files
    102084 thumbs
      102085 102.jpg

=cut
