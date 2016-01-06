#!/bin/perl

# I frequently search for files (eg, mlocate/slocate) where I know the
# ending part of a file; this program efficiently searches for them
# using bc-sgrep.pl and a list of files sorted in reverse
# --create: just create revfiles.txt, don't search anything

require "/usr/local/lib/bclib.pl";
# option_check(["create"]);

# if ($globopts{create}) {
  # TODO: perl inside perl seems ugly
#  system("bzcat /usr/local/etc/weekly-backups/files/bcunix-files.txt.bz2 | perl -nle 's%^.*?\/%/%; print $_' | rev | sort > /mnt/sshfs/revfiles.txt");
#  exit;
# }

# TODO: allow more than one argument
my($phrase) = @ARGV;
$phrase = reverse($phrase);

# non-glob files below are expected to exist

# extdrive5 thing is a short-term special case hack
my(@exts) = glob("/mnt/extdrive*/*-files-rev.txt /mnt/extdrive5/?????/*-files-rev.txt");

for $i ("/mnt/sshfs/bcmac-files-rev.txt.srt", "/bcunix-files-rev.txt", @exts) {
  # TODO: also search for $phrase.bz2 (reversed) and so on?
  system("/home/barrycarter/BCGIT/bc-sgrep.pl '$phrase' $i | rev");
}
