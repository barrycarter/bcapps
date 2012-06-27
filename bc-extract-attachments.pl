#!/bin/perl

# Hideous hack: finds pieces of messages that "look like" MIME
# attachments and stores them in files, replacing the attachment with
# a text string

require "/usr/local/lib/bclib.pl";

(($file) = shift) || die("Usage: $0 filename");

# handle bzipped files
if ($file=~/\.bz2$/) {
  open(A,"bzcat $file|")||die("Can't open pipe $file, $!");
} else {
  open(A,$file)||die("Can't open $file, $!");
}

chdir(tmpdir("bc-extract"));
debug("DIR: $ENV{PWD}");

while (<A>) {
  # handle message we just saw (handle_msg'll ignore empty call on first msg)
  if (/^From /) {
    $num++;
    handle_attachments($msg);
    $msg=$_;
  } else {
#    debug("READ: $_");
    $msg = "$msg$_";
  }
}

# last one
handle_attachments($msg);

# sample MIME line:
# MDAwOTg2IDY1NTM1IGYNCjAwMDAwMDA5ODcgNjU1MzUgZg0KMDAwMDAwMDk4OCA2NTUzNSBmDQow

sub handle_attachments {
  my($msg) = @_;

  debug("MSG: $msg");

  $msg=~/^([a-zA-Z0-9\+]+)$/;
  debug("1: <$1>");

  

#  while ($msg=~/([a-zA-Z0-9\+\n]{5,})/s) {
#    debug("THUNK: $1");
#  }

#  my($thunk) = $1;

#  if ($thunk) {debug("THUNK: $thunk");}

#  debug("GOT: $msg");
}

