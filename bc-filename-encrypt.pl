#!/bin/perl

# symmetrically encrypts filenames: many online backup services
# encrypt file content, but not file names; this is a simple script
# that creates links to files but with the link name being encrypted

require "bclib.pl";

# TODO: don't hard code this (sample directory for now)
($out, $err, $res) = cache_command("find /home/barrycarter/MP3 -type f", "age=3600");

debug($out);


