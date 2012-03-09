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

# Tried this in sqlite3 once, but sense postgresl/mysql or flat files
# might be better

# bc-filename-encrypt.pl will become a part of this, most likely

# TODO: sort/uniq can cleanup dupes when needed

require "bclib.pl";

=item schema

Data we store (whether in an SQL table or flat file):

filedata: hostid path mtime sha1sum

backupdata: sha1sum where-stored

symlinks: hostid path mtime target (merge w/ filedata?)

=cut
