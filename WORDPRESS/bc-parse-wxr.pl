#!/bin/perl

# gave up on YAML, parsing XML instead

require "/usr/local/lib/bclib.pl";

# TODO: reminder to self: use latest version of blog, not test version

# TODO: the \s* below are probably superfluous

my(@strs, $in_blog, %hash, $curtag);

while (<>) {


  # ignore comments
  if (/^\s*<!--/) {next;}

  # end of item? parse it!, reset hash
  if (m%^\s*</item>%) {
    debug("SENDING HASH:",%hash);
    parse_item(\%hash);
    %hash = ();
  }

  # treat categories and authors special
  if (/^\s*<wp:(author|category)>/) {parse_meta($_); next;}

  # single line tag? parse and move on
  if (s%\s*<(.*?)>([^<>]*?)</\1>%$hash{$1}=$2%es) {next;}

  # start of new tag? start assignment to $hash{newtag} + set curtag
  if (s%\s*<(.*?)>(.*)%%) {
    $hash{$1} = $2;
    $curtag = $1;
  }

  # TODO: handle end of curtag!

  # anything else is appended to curtag
  $hash{$curtag} .= $_;

  debug("HAST ATM:",%hash);
}

sub parse_item {

  # TODO: there must be a better (uglier) way to do this
  my($hashref) = @_;
  my(%hash) = %{$hashref};

  if ($hash{"wp:post_type"}=~m/attachment/i) {
    debug("SKIPPING attachment: $hash{title}");
    return;
  }

  debug("HASH:",%hash);
  return;


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
