#!/bin/perl

# --hostid: use this hostid, not the one from `hostid`

# This is a shell <h>(as in snails, not tcsh)</h> for a backup program
# with these properties:
#
#   - encrypts filenames, not just file content
#   - saves files based on sha1 (duplicate files stored just once)
#   - can backup a single directory, but keeps track of what's been backed up globally
#   - versioning
#   - creates backup "chunks" of a given size (eg, fit to DVD), and remembers what its backed up
#   - avoids expensive operations (such as sha1) when possible (or even find without an mtime)

# Tried this in sqlite3 once, but sense postgresl/mysql or flat files
# might be better

# bc-filename-encrypt.pl will become a part of this, most likely

# TODO: sort/uniq can cleanup dupes when needed
# TODO: keep plaintext and encrypted versions of each "table"
# TODO: splitting into multiple files won't kill us?

# NOTE: assumes if a file's timestamp hasn't changed, neither has the
# content (fails for special case of wikipediafs, alas)

# conceptually, this program does two things:
# converts machine/file/time to sha1sum
# converts sha1sum to backed-up-location

require "bclib.pl";

# determine hostid (yes, it's global)
$hostid = $globopts{hostid}||`hostid`||die("hostid is 0 or doesn't exist");

backdir("/home/barrycarter/MP3");

# "backup" a directory
sub backdir {
  my($dir) = @_;

  # TODO: indicate that dir is being backed up now
  # TODO: only find files more recent that last backup
  # TODO: (or parent dirs? but could be probs w symlinks)
  # TODO: caching only while testing (null separator is cleaner)
  # TODO: allow sorting (so "most important" files definitely backed up)
  # we need timestamp to check for dupes; we get size "JFF" since it's easy
  my($out, $err, $res)=cache_command("find $dir -type f -print0 -printf '%s %T\@ '", "age=3600");

  # list of files
  my(@files) = split(/\0/, $out);
  debug("FILES",@files);
}


=item schema

Data we store (whether in an SQL table or flat file):

(note that 'size' below is redundant)
filedata: hostid path mtime sha1sum size

backupdata: sha1sum where-stored

symlinks: hostid path mtime target (merge w/ filedata?)

timestamps: dir when-last-backed-up

CREATE TABLE filedata (
 hostid TEXT,
 path TEXT,
 mtime FLOAT,
 sha1sum TEXT,
 size INT
);



=cut
