#!/bin/perl

# quick and dirty wrapper to scanimage: takes a 300 dpi full page scan
# and outputs it to a unique file in the current directory

# If it weren't for the `backticks`, this could be an alias?

system("sudo scanimage --resolution 300 > `date +%Y%M%d.%H%M%S.%N` &");

