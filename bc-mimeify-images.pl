#!/bin/perl

# This one off converts IMG SRC in a file to base64 so the file is
# consistent w/o any external references; this implementation is very
# specific to my case, and others have done more general cases

# href='data:image/png;base64,$b64
require "/usr/local/lib/bclib.pl";

my($data,$fname) = cmdfile();

$data=~s/<img src="(.*?)"/'<img src="'.tob64($1).'"'/eg;

print $data;


sub tob64 {
  my($img) = $1;

  $img=~/\.(.*?)$/;
  my($ext) = $1;

  # /usr/local/etc/bookcovers happens to be the parent dir here
  my($data) = encode_base64(read_file("/usr/local/etc/bookcovers/$img"));
  $data=~s/\s//g;

  return "data:image/$ext;base64,$data";
}
