#!/bin/perl

# determines which codes in codelist.txt can't be found using bc-cityfind.pl

push(@INC,"/usr/local/lib");
require "bclib.pl";

@codes = split(/\n/, read_file("codelist.txt"));

# use remote bc-cityfind to see which ones resolve
# TODO: this is really really ugly; ssh root\@remote is such a bad idea!

$arg = join(" ",@codes);

# in theory, bc-cityfind.pl can take any number of args, but let's try
# 16 at a time

while (@codes) {
  @slice = splice(@codes,0,16);
  $args = join(" ",@slice);
  debug($args);

  # this will not work for most people, just use bc-cityfind.pl
  # (requires geonames2.db, which I personally don't have locally, sigh)
  $cmd = "ssh -i /home/barrycarter/.ssh/id_rsa.bc root\@barrycarter.info bc-cityfind.pl $args";

  # geonames2.db rarely changes, so cache for 10 days (though I'm pretty
  # sure tmpwatch will clean it up before then)
  ($out,$err,$res) = cache_command($cmd,"age=864000");

  debug($out,$err,$res);
}
