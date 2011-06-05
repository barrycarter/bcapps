#!/bin/perl

# Extracts attachments from a given mailbox, and stores them in
# consistent "sha1" format. Recreates mailbox with pointers to
# attachment files

require "bclib.pl";

# list of types we can handle (excl image/jpeg and octet-stream, which
# are handled anyway)

(($file) = shift) || die("Usage: $0 filename");

open(A,$file)||die("Can't open $file, $!");

chdir(tmpdir("bc-extract"));
debug("DIR: $ENV{PWD}");

while (<A>) {
  # handle message we just saw (handle_msg'll ignore empty call on first msg)
  if (/^From /) {
    $num++;
    handle_attachment($msg);
    $msg=$_;
  } else {
    $msg = "$msg$_";
  }
}

# last one
handle_attachment($msg);

sub handle_attachment {
  my($a)=@_;
  my($fname, $ctype, $bound);
  # need a global to preserve uniqueness
  $attachnum++;
  debug("ATTACHNUM: $attachnum");

  # split attachment (which might be entire msg) into head and body pieces
  # this also covers empty case
  unless ($a=~/^(.*?)\n\n(.*)$/s) {
    warnlocal("Can't split attachment into head/body, ignoring");
    return;
  }

  my($head,$body)=($1,$2);

  # if multipart, get content-type and boundary (if not, just get content-type)
  if ($head=~/Content-[Tt]ype: (.*?); boundary="(.*?)"/m) {
    ($ctype, $bound) = ($1,$2);
  } elsif ($head=~/Content-[Tt]ype: (.*?)(\;|$)/m) {
    $ctype = $1;
  } else {
    warnlocal("Can't find content-type, ignoring");
    return;
  }

  my($ctype)=$1;

  # is this a multipart msg? if so, recurse
  if ($ctype=~m!multipart/(.*?)!i) {
    unless ($bound) {
      warnlocal("Multipart message has no boundary");
      return;
    }

    debug("multipart msg, boundary: $bound");
    while ($body=~s/\n\-\-\Q$bound\E(.*?)\n\-\-\Q$bound\E/\n--$bound/s) {
      $attach=$1;
      handle_attachment($attach);
    }
    return;
  }

  # otherwise, regular old attachment
  # we don't want to extract text/html attachments
  if ($ctype=~m!text/(plain|html)!) {return();}

  if ($head=~/name=\"(.*?)\"/) {$fname=$1;} else {$fname="";}
  write_file($body, "attach-$attachnum.b64");
  system("base64 -d attach-$attachnum.b64 > attach-$attachnum.dat");
}




