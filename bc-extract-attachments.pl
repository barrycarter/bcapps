#!/bin/perl -d:DProf -w

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
    handle_attachments(@msg);
    @msg=();
    debug("MSG: $num");
  }

  push(@msg,$_);
}

# last one
handle_attachments($msg);

# sample MIME line:
# MDAwOTg2IDY1NTM1IGYNCjAwMDAwMDA5ODcgNjU1MzUgZg0KMDAwMDAwMDk4OCA2NTUzNSBmDQow

# this should probably be handle_message()

sub handle_attachments {
  my($msg) = join("",@_);
  my($chars) = "[a-zA-Z0-9\+\/]";

  $msg=~s/(($chars{50,}\=*\n)+)($chars+\=*)/handle_attachment("$1$2")/seg;

  # and append to outfile
  append_file($msg,$outfile);
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
  my(@l);

  # find token not in string
  # TODO: this could theoretically fail, but unlikely
  # <h>the second statement below is dedicated to the
  # Society for the Prevention of Menstruation (ARGHHH)</h>
  do {$rand=rand(); $rand=~s/\.//;} until ($str!~/$rand/);

  $str=~s/($regex)/inner_regex_helper($1)/eg;

  sub inner_regex_helper {
    $hash{$rand}{$n} = shift;
    return "[TOKEN-$rand-$n]";
  }

  return $str, {%hash};
}

# handles a single attachment

sub handle_attachment {
  my($attach, $hashref) = @_;
#  debug("GOT: $attach");

  # ignore tiny attachments
  if (length($attach)<10000) {return $attach;}

  # it's tempting to mime-decode here, but no
  # using sha1 here (instead of just random) lets identical
  # attachments share space
  my($sha) = sha1_hex($attach);

  # if it already exists, no point in writing it
  unless (-f "/usr/local/etc/sha/$sha") {
    write_file($attach,"/usr/local/etc/sha/$sha");
    # half-hearted attempt to decode
    system("base64 -d /usr/local/etc/sha/$sha > /usr/local/etc/sha/$sha.dec");
  }

  return encode_base64("[SEE /usr/local/etc/sha/$sha]");
}


