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
  # could I use redo here?
  # handle message we just saw (handle_msg'll ignore empty call on first msg)
  if (/^From /) {
    $num++;
    handle_attachments($msg);
  }

  $msg = "$msg$_";

  # potential MIME line?
  if (/^[a-z0-9\+\/]+$/i) {
    push(@{$attach{$an}}, $_);
  } else {
    # a non-MIME line means we MUST advance $an, even though this will
    # lead to big gaps in the numbering of %attach (which is one of
    # the reasons it's a hash and not an array)
    $an++;
  }
}

# last one
handle_attachments($msg);

# sample MIME line:
# MDAwOTg2IDY1NTM1IGYNCjAwMDAwMDA5ODcgNjU1MzUgZg0KMDAwMDAwMDk4OCA2NTUzNSBmDQow

sub handle_attachments {
  my($msg) = @_;

  debug("MSG: $msg");

  debug("ATTACH(",unfold({%attach}),")");

  # only match "big" attachments

  # TODO: this could theoretically capture text, but until we have
  # nested regexs, can't do much about this (except write my own
  # parser, not necessarily a bad idea)
  # TODO: 32767 is max Perl allows below
#  while ($msg=~s/([a-zA-Z0-9\+\n\/\=]{32767,})//s) {
#    debug("1: <$1>");
#  }

  

#  while ($msg=~/([a-zA-Z0-9\+\n]{5,})/s) {
#    debug("THUNK: $1");
#  }

#  my($thunk) = $1;

#  if ($thunk) {debug("THUNK: $thunk");}

#  debug("GOT: $msg");
}

