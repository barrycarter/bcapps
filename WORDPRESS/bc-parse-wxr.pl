#!/bin/perl

# gave up on YAML, parsing XML instead

require "/usr/local/lib/bclib.pl";

# TODO: reminder to self: use latest version of blog, not test version

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
  my(%hash);

#  debug("<GOT>$str</GOT>");

  # TODO: this is not proper XML parsing (and probably never will be)
  # Among other things, this assumes open tags have no extra info
  # ignoring HTML tags, only want wp tags
  while ($str=~s%<(wp:.*?)>([^<>]*?)</\1>%$hash{$1}=$2%es) {}

  # TODO: ignoring attachments/media now, can't do long term
  if ($hash{"wp:post_type"}=~m/attachment/i) {next;}

  debug("HASH",%hash);
}
