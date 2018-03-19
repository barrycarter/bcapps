#!/bin/perl

# uses MTP commands to sync my phone to ~/MYPHONE <h>(original name, huh?)</h>

require "/usr/local/lib/bclib.pl";

my($out, $err, $res);

# cache results for one hour, just in case of connection issues
($out, $err, $res) = cache_command2("sudo mtp-files", "age=3600");

# debug($out);

my(@files) = split(/^File ID: /m, $out);

for $i (@files) {

  # the file ID

  $i=~s/^\s*(\d+)\s*//;
  my($id) = $1;

  debug("ID: $id");
}

