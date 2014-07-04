#!/bin/perl

# given the result of a Special:Export page, restore pages in given directory

require "/usr/local/lib/bclib.pl";
$pagedir = "/usr/local/etc/metawiki/pbs3";

# TODO: for now, source file and target dir are fixed
$all = read_file("/home/barrycarter/Download/Pearls+Before+Swine-20140704022551.xml");

while ($all=~s%<page>(.*?)</page>%%s) {
  my($page) = $1; 
  $page=~s%<text .*?>(.*?)</text>%%s;
  my($text) = $1;
  $page=~s%<title>(.*?)</title>%%s;
  my($title) = $1;
  debug("WRITING: $title");
  write_file("$text\n", "$pagedir/$title.mw");

  # this is a major hack so bc-mirror-mw-attr.pl doesn't mirror these
  # files back to the wiki (since they are known current)
  my($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks)=stat("$pagedir/$title.mw");
  system("chattr -v $mtime \"$pagedir/$title.mw\"");
}

