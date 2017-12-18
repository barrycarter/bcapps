#!/bin/perl

# parses the YAML output of "wp-cli" (not the XML dumps from the WP
# web interfacace)

# NOTE: I probably could use the Perl YAML modules, but don't think
# they're necessary for something this simple

require "/usr/local/lib/bclib.pl";

# TODO: change target dir
# target dir is where each post is written to a file
my($targetdir) = "/home/user/20171218/wp";

# ignore the first separators
# TODO: this doesnt work unless you actually redirect STDIN, hmmm
# my($tridash) = <>;
# my($onedash) = <>;
# unless ($tridash eq "---" && $onedash eq "-") {die("BAD YAML ON STDIN");}

my(%hash, $key);

while (<>) {

  if (++$count > 10000) {die "TESTING";}

  chomp;

  if ($_ eq "- " || eof()) {
    # parse yaml and clear hash
    debug("PARSING...");
    parse_yaml(\%hash);
    %hash = ();
    next;
  }

  # TODO: assuming two spaces = YAML key
  if (s/^  (\S+?):\s*//) {$key = $1;}

  debug("GOT: $_");
  debug("KEY: $key");

  # always append to curkey
  $hash{$key} .= $_;
}

# this is a one-off for this program, not generalized

sub parse_yaml {
  my($hashref) = @_;
  my(%hash) = %{$hashref};

  # ignore unpublished posts
  unless ($hash{post_status} eq "publish") {return;}

  # figure out filename
  # TODO: this might be redundant
  my($fname) = $hash{post_name};

  if ($fname=~m/^\s*$/) {
    warn("BAD POST NAME FOR LIVE POST: ...");
    debug(%hash);
    next;
  }

  local(*A);
  open(A, ">$targetdir/$fname.wp");

  # all fields except content
  for $i (sort keys %hash) {
    if ($i eq "post_content") {next;}
    print A "$i: $hash{$i}\n";
  }

  # TODO: remove weird pipe things surrounding content

  # real newlines cleanup YAML spaces
  $hash{post_content}=~s/\r/\n/sg;
  # TODO: this might kill intentional indentation (intended indentation?)
  $hash{post_content}=~s/^\t//mg;


  # a separator, and then content
  print A "\n","="x60,"\n$hash{post_content}\n";

  close(A);

  # TODO: parse author/category properly
  debug("GOT HASH",%hash);
}


