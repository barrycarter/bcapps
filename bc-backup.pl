#!/bin/perl

# This is a shell <h>(as in snails, not tcsh)</h> for a backup program
# with these properties:
#
#   - encrypts filenames, not just file content
#   - saves files based on sha1 (duplicate files stored just once)
#   - can backup a single directory, but keeps track of what's been backed up globally
#   - versioning

# Tried this in sqlite3 once, but sense postgresl/mysql or flat files
# might be better

# bc-filename-encrypt.pl will become a part of this, most likely
