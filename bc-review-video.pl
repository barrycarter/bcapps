#!/bin/perl

# Plays video files in a given directory, and allows me to mark them
# "watched", "bad" (cannot be played), etc

require "/usr/local/lib/bclib.pl";

my($dir) = @ARGV;
unless (-d $dir) {die "Usage: $0 <directory>";}

# reverse time order here is just useful for me?
# cache_command below: it can sometimes be slow to get info from remote mount
my($files) = cache_command2("ls -t $dir","age=3600");

debug("FILES: $files");

