#!/bin/perl

# parses the YAML output of "wp-cli" (not the XML dumps from the WP
# web interfacace)

# NOTE: I probably could use the Perl YAML modules, but don't think
# they're necessary for something this simple

require "/usr/local/lib/bclib.pl";

# ignore the first separators
# TODO: this doesnt work unless you actually redirect STDIN, hmmm
# my($tridash) = <>;
# my($onedash) = <>;
# unless ($tridash eq "---" && $onedash eq "-") {die("BAD YAML ON STDIN");}

my(%hash, $key);

while (<>) {

  chomp;

  debug("GOT: *$_*");

  if ($_ eq "- " || eof()) {
    # parse yaml and clear hash
    debug("PARSING...");
    parse_yaml(\%hash);
    %hash = ();
    next;
  }

  # TODO: assuming two spaces = YAML key
  if (s/^  (.*?):\s*//) {$key = $1;}

  # always append to curkey
  $hash{$key} .= $_;
}

# this is a one-off for this program, not generalized

sub parse_yaml {
  my($hashref) = @_;
  my(%hash) = %{$hashref};

  debug("GOT HASH",%hash);
}


