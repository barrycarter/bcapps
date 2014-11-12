#!/bin/perl

# does exactly what sqlite32rss.pl does, but formatted and improved
# for IFTTT which requires a specific feed format

# given the output of sqlite3 -line -batch, create an RSS feed
# --title: feed title
# --desc: channel description
# --noheader: suppress the header, useful for testing

require "/usr/local/lib/bclib.pl";

unless ($globopts{noheader}) {print "Content-type: text/xml\n\n";}

# TODO: $title is not always URL, fix this!

print << "MARK";
<?xml version="1.0" encoding="ISO-8859-1" ?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
<channel>
<atom:link href="http://$globopts{title}" rel="self" type="application/rss+xml" />
<title>$globopts{title}</title>
<link>https://github.com/barrycarter/bcapps/blob/master/bc-run-sqlite3-query2.pl</link>
<description>$globopts{desc}</description>

MARK
;

# read in the entire STDIN
local($/) = 0777;
my($all) = <STDIN>;

# and split on double newline
for $item (split(/\n\n/, $all)) {
  # if there is a title field, use it
  if ($item=~s/title\s+\=\s+(.*?)$//) {$title=$1;} else {$title="Untitled";}

  # list of fields, separated by commas
  $item=~s/\n/, /g;
  $item=~s/\s+\=\s+/: /g;
  $item=~s/\s+/ /g;
  $ENV{TZ} = "GMT";
  my($date) = `date -R`;
  $date=~s/\n//s;
#  $guid = sha1_hex($item);
print << "MARK";
<item><title>$title</title><link>http://barrycarter.info</link>
<description>$item</description>
<guid>http://$globopts{title}</guid>
<pubDate>$date</pubDate>
</item>
MARK
;
}

print << "MARK";
</channel></rss>
MARK
;
