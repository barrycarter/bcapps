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

while (<A>) {
  # handle message we just saw (handle_msg'll ignore empty call on first msg)
  if (/^From /) {
    $num++;
    handle_msg($msg);
    $msg=$_;
  } else {
    $msg = "$msg$_";
  }

  if ($num>10) {die "TESTING";}
}

sub handle_msg {
  my($msg) = @_;
  my($fname, $attach);

#  debug("handle_msg($msg)");

  # if message is totally blank, ignore
  unless ($msg) {
    warnlocal("message is empty");
    return;
  }

  # divide into header/body
  unless ($msg=~/^(.*?)\n\n(.*)$/s) {
    warnlocal("message has no header/body");
    return;
  }

  my($head,$body)=($1,$2);

  # fix continued lines in head
  $head=~s/\n\s+/ /sg;

  unless ($head=~/^Content-[tT]ype: (.*?)(;.*)?$/m) {
    warnlocal("message has no content-type in header");
    return;
  }

  ($type,$extra)=($1,$2);

  # cleanup odd spaces
  $type = trim($type);

  # uninteresting messages
  if ($type=~m!text/plain!i || $type=~m!text/html!i || $type=~m!multipart/report!i) {
    debug("message consists only of text or other uninteresting attachments");
    return;
  }

  # message contains at most one attachment
  if ($type eq "application/octet-stream" || $type eq "image/jpeg") {
    handle_attach($body);
    return;
  }

  # types we can handle
  unless ($type=~m!multipart/(mixed|alternative|related|signed)!i || $type eq "text") {
    warnlocal("Unknown type: $type");
    return;
  }

  # main case below, file contains multiple MIME attachments
  unless ($extra=~/boundary=\"(.*?)\"/i || $extra=~/boundary=([^\s]+)/i) {
    warnlocal("message has no MIME boundary");
    # <h>I need boundaries, man</h>
    return;
  }

  my($boundary)=$1;
  debug("BOUNDARY: $boundary");

  while ($body=~s/\n\-\-\Q$boundary\E(.*?)\n\-\-\Q$boundary\E/\n--$boundary/s) {
    $attach=$1;
    handle_attachment($attach);
  }

  # if the last attachment is incomplete, handle it below
  unless ($body=~s/^\s*\-\-\Q$boundary\E\n//s) {
    warnlocal("LEFTOVER: $body");
    return;
  }

  handle_attachment($body);
}

sub handle_attachment {
  my($a)=@_;
  my($fname);
  $attachnum++;
  # split attachment into head and body pieces
  unless ($a=~/^(.*?)\n\n(.*)$/s) {
    warnlocal("Can't split attachment into head/body, ignoring");
    return;
  }

  my($head,$body)=($1,$2);

  unless ($head=~/Content-[Tt]ype: ([^;\n]*)/m) {
    warnlocal("Can't find content-type, ignoring");
    return;
  }

  $ctype=$1;

  # boring attachment
  if ($ctype=~m!text/(plain|html)!) {return();}

  debug("CTYPE: $ctype, ATTACH:",$a);
  # TODO: combine this code w/ code above for JPEG/octetstream (why different?)
  if ($head=~/name=\"(.*?)\"/) {$fname=$1;} else {$fname="";}
  write_file($body, "attach-$attachnum.b64");
  system("base64 -d attach-$attachnum.b64 > attach-$attachnum.dat");
}




