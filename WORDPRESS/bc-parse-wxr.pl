#!/bin/perl

# gave up on YAML, parsing XML instead

require "/usr/local/lib/bclib.pl";

# TODO: reminder to self: use latest version of blog, not test version

my(@strs, $in_blog);

while (<>) {

  my(%hash);

  # ignore comments
  if (/^\s*<!--/) {next;}

  # treat categories and authors special
  if (/^\s*<wp:(author|category)>/) {parse_meta($_); next;}

  # single line tag? parse and move on
  if (s%\s*<(.*?)>([^<>]*?)</\1>%$hash{$1}=$2%es) {

    debug("ASSIGN: $1 -> $2");

    next;
  }

  debug("GOT: $_, HASH",%hash);

  warn "TESTING";
  next;



  # ugly way to skip crap
  if (/<item>/) {$in_blog = 1;}

  unless ($in_blog) {next;}

  chomp;

  debug("READING: $_");



  push(@strs, $_);

  debug("STRS LEN: $#strs+1");

  # TODO: this makes many assumptions about the WXR format, including:
  #   - the </item> tag appears on a line by itself

  if (m%</item>%) {

    # parse what we've got and clear for next
    parse_xml(@strs);
    debug("RESETTING STRS");
    @strs = ();
    debug("STRS LEN NOW: $#strs+1");
  }
}


sub parse_xml {
  my(@strs) = @_;
  my($str) = join("\n",@strs);
  my(%hash);

  debug("ARRAY LEN: $#strs+1, STR LENGTH: ".length($str));

#  debug("<GOT>$str</GOT>");

  # TODO: this is not proper XML parsing (and probably never will be)
  # Among other things, this assumes open tags have no extra info
  # ignoring HTML tags, only want wp tags

#  while ($str=~s%<(wp:.*?)>([^<>]*?)</\1>%$hash{$1}=$2%es) {}

  # turns out not all important tags start with wp:, so ...
  debug("STARTING WHILE");
  while ($str=~s%<(.*?)>([^<>]*?)</\1>%$hash{$1}=$2%es) {}
  debug("ENDING WHILE");

  # TODO: ignoring attachments/media now, can't do long term
  if ($hash{"wp:post_type"}=~m/attachment/i) {
    debug("SKIPPING attachment: $hash{title}");
    return;
  }

  debug("HASH",%hash);
}

sub parse_meta {
  my($line) = @_;
  debug("GOT: $line, oding nothing for now");
}
