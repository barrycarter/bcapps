#!/bin/perl

# gave up on YAML, parsing XML instead

require "/usr/local/lib/bclib.pl";

my(@strs, $in_blog);

while (<>) {

  # ugly way to skip crap
  if (/<item>/) {$in_blog = 1;}
  unless ($in_blog) {next;}

  chomp;
  push(@strs, $_);

  # TODO: this makes many assumptions about the WXR format, including:
  #   - the </item> tag appears on a line by itself

  if (m%</item>%) {

    # parse what we've got and clear for next
    parse_xml(@strs);
    @strs = ();
  }


}


sub parse_xml {
  my(@strs) = @_;
  my($str) = join(" ",@strs);

  debug("<GOT>$str</GOT>");

  # TODO: this is not proper XML parsing (and probably never will be)
  # Among other things, this assumes open tags have no extra info
  while ($str=~s%<([^<>]*?)>(.*?)</\1>%%s) {
    debug("PARSED: $1 -> $2");
  }

}
