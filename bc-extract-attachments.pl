#!/bin/perl

# Hideous hack: finds pieces of messages that "look like" MIME
# attachments and stores them in files, replacing the attachment with
# a text string

# Options:
# --overwrite: overwrite output file (only for testing!)

die "DO NOT USE; Perl 32767 char regexp error breaks this program";

require "/usr/local/lib/bclib.pl";

(($file) = shift) || die("Usage: $0 filename");

$outfile = "$file.extracted";

# during testing only
$globopts{debug} = 1;

# in test mode, delete the attachment I'm having trouble with, forcing
# prg to re-create it

if ($globopts{test}) {system("rm /usr/local/etc/sha/372765976e150ed47f3449f1e1c07087cd41e0de /usr/local/etc/sha/2abca5a6deb95baf32bdab1b4d5ffedf0476166c");}

if (-f $outfile && !$globopts{overwrite}) {
  die ("$outfile exists and I'm too chicken to overwrite it");
}

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
handle_attachments(@msg);

# during testing only
system("bc-check-extract-attachments.pl --debug $file");

# sample MIME line:
# MDAwOTg2IDY1NTM1IGYNCjAwMDAwMDA5ODcgNjU1MzUgZg0KMDAwMDAwMDk4OCA2NTUzNSBmDQow

# this should probably be handle_message()
sub handle_attachments {
  my($msg) = join("",@_);
  my($chars) = "[a-zA-Z0-9\+\/]";

  # note that $2 is just the last line repeated
  $msg=~s/(\n($chars{50,}\=*\n)+)($chars+\=*\n)/handle_attachment("$1$3")/seg;

  # and append to outfile
  append_file($msg,$outfile);
}

# handles a single attachment
sub handle_attachment {
  my($attach, $hashref) = @_;

  debug("ATTACHMENT",$attach);

  # ignore tiny attachments
  if (length($attach)<10000) {return $attach;}

  # because I'm going to return two newlines anyway, strip them here
  $attach=~s/^\n//s;
  $attach=~s/\n$//s;

  # it's tempting to mime-decode here, but no
  # using sha1 here (instead of just random) lets identical
  # attachments share space
  my($sha) = sha1_hex($attach);
  debug("SHA: /usr/local/etc/sha/$sha");

  # if it already exists, no point in writing it
  unless (-f "/usr/local/etc/sha/$sha") {
    write_file($attach,"/usr/local/etc/sha/$sha");
    # half-hearted attempt to decode
    system("base64 -d /usr/local/etc/sha/$sha > /usr/local/etc/sha/$sha.dec");
  }

  my($ret) = encode_base64("[SEE /usr/local/etc/sha/$sha]");

  # nuke internal newlines to base64, surround with newlines
  $ret=~s/\n//isg;
  $ret="\n$ret\n";
  return $ret;
}


