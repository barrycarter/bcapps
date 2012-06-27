#!/bin/perl

# Hideous hack: finds pieces of messages that "look like" MIME
# attachments and stores them in files, replacing the attachment with
# a text string

# Options:
# --overwrite: overwrite output file (only for testing!)

require "/usr/local/lib/bclib.pl";

(($file) = shift) || die("Usage: $0 filename");

warn "TESTING";
$outfile = "/home/barrycarter/20120627/outfile";

if (-f $outfile && !$globopts{overwrite}) {
  die ("$outfile exists and I'm too chicken to overwrite it");
}

# this prevents appending to an existing file
system("rm $outfile");

# handle bzipped files
if ($file=~/\.bz2$/) {
  open(A,"bzcat $file|")||die("Can't open pipe $file, $!");
} else {
  open(A,$file)||die("Can't open $file, $!");
}

while (<A>) {
  # could I use redo here?
  # handle message we just saw (handle_msg'll ignore empty call on first msg)
  if (/^From /) {
    $num++;
    handle_attachments($msg);
    $msg = "";
    debug("MSG: $num");
  }

  $msg = "$msg$_";
}

# last one
handle_attachments($msg);

# sample MIME line:
# MDAwOTg2IDY1NTM1IGYNCjAwMDAwMDA5ODcgNjU1MzUgZg0KMDAwMDAwMDk4OCA2NTUzNSBmDQow

sub handle_attachments {
  my($msg) = @_;
  my($rand);
  my($chars) = "[a-zA-Z0-9\+\/]";

  # tokenize mime-like lines
  # could theoretically capture long words, but handle_attachment
  # should take care of that
  my($str, $hashref) = inner_regex($msg, "$chars\{50,\}\=?\n");
  my(%hash) = %{$hashref};
#  debug("STR:",$str,"HASHREF:",$hashref);

  # what was the random key?
  # TODO: should inner_regex just return this too?
  ($rand) = keys %hash;

  # and now, handle each attachment (including last line of MIME
  # characters that may be less than 50 in length
  # TODO: the inner regex isn't matched, so I should use symbols to
  # reduce CPU work
  $str=~s/((?:\[TOKEN-$rand-\d+\]\n)+)($chars+\=?)/handle_attachment("$1$2",$hashref)/esg;

  # and append to outfile
  append_file($str,$outfile);

  return;
}

=item inner_regex($str, $regex, $options)

Given string $str, replace $regex with token string that's guarenteed
not to appear in $str itself. Return the parsed string and a hash
mapping the replacement back to the original string.

$options currently unused

TODO: not super happy with [TOKEN-], don't really need it.

TODO: should I be using Perl::Tokenize or similar here?

=cut

sub inner_regex {
  my($str, $regex, $options) = @_;
  my($n, $token, %hash) = (0);

  # find token not in string
  # TODO: this could theoretically fail, but unlikely
  # <h>the second statement below is dedicated to the
  # Society for the Prevention of Menstruation (ARGHHH)</h>
  do {$rand=rand(); $rand=~s/\.//;} until ($str!~/$rand/);

  while ($str=~s/($regex)/[TOKEN-$rand-$n]\n/) {
    $hash{$rand}{$n} = $1;
    $n++;
  }

  return $str, {%hash};
}

# handles a single attachment

sub handle_attachment {
  my($attach, $hashref) = @_;
#  debug("GOT: $attach");

  # find the random key I'm dealing with
  my(%hash) = %{$hashref};
  my($rand) = (keys %hash);

  # convert attachment back to what it was
  $attach=~s/\[TOKEN-$rand-(\d+)\]\n/$hash{$rand}{$1}/sg;

  # it's tempting to mime-decode here, but no
  # using sha1 here (instead of just random) lets identical
  # attachments share space
  my($sha) = sha1_hex($attach);

  # if it already exists, no point in writing it
  unless (-f "/usr/local/etc/sha/$sha") {
    write_file($attach,"/usr/local/etc/sha/$sha");
  }

  return "[SEE /usr/local/etc/sha/$sha]";
}

