#!/bin/perl

# given the output of sqlite3 -html, create an RSS feed
# doesn't work if query has tables inside it
require "bclib.pl";

print << "MARK";
<?xml version="1.0" encoding="ISO-8859-1" ?><rss version="0.91">
<channel><title>title</title><description>channel desc</description>

MARK
;


while (<STDIN>) {
  # start of new item, which is also title
  # note that table inside description must be escaped
  s%^<tr><td>(.*?)</td>$%<item><title>$1</title><description>&lt;table border&gt;&lt;tr&gt;%i;

  # end of item
  s%^</tr>$%&lt;/&lt;/tr&gt;table&gt;</description></item>%i;

  # all else is part of the description (as a table cell w/ escaped HTML)
  if (/^<td>/i) {
    s/</&lt;/g;
    s/>/&gt;/g;
  }

  print $_;
}

print << "MARK";
</channel></rss>
MARK
;
