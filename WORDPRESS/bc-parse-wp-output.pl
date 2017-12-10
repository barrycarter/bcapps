#!/bin/perl

# parses the YAML output of "wp-cli" (not the XML dumps from the WP
# web interfacace)

# NOTE: I probably could use the Perl YAML modules, but don't think
# they're necessary for something this simple

require "/usr/local/lib/bclib.pl";

while (<>) {

  chomp;
  debug("GOT: $_");
}

