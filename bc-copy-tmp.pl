#!/bin/perl

# copies the given file or files to /tmp/[extension] where [extension]
# is 1st arg, but numbering as needed

# Example: $0 foo.xyz would copy files to /tmp/foo1.xyz and so on

require "/usr/local/lib/bclib.pl";

my($ext) = shift(@ARGV);

if (!$ext) {die "Usage: $0 extension filename filename filename...";}

if ($ext=~m%/%) {die ("$ext contains /, not allowed");}

unless ($ext=~s/^(.*?)\.(.*)$//) {
  die "$ext must contain exactly one dot";
}

my($base, $ext) = ($1,$2);

my($num);

for $i (@ARGV) {

  unless (-f $i) {warn "$i DOES NOT EXIST"; next;}

  # increment number as long as file exists
  while (-f "/tmp/$base$num.$ext") {$num++;}
  $target = "/tmp/$base$num.$ext";

  my($out, $err, $res) = cache_command2("cp $i $target");
  if ($res) {
    warn "Copy failed";
  } else {
    print "Copied $i to $target\n";
  }
}






  


