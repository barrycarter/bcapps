#!/bin/perl

# given the output of sqlite3 -html -header, create an RSS feed
# doesn't work if query has tables inside it
push(@INC,"/usr/local/lib");
require "bclib.pl";

print << "MARK";
Content-type: text/xml

<?xml version="1.0" encoding="ISO-8859-1" ?><rss version="0.91">
<channel><title>title</title><description>channel desc</description>

MARK
;

# converting angle brackets to &sh; like this for ease
$tabstart = "<table border><tr>";
$tabend = "</tr></table>";

$tabstart=~s/</&lt;/isg;
$tabstart=~s/>/&gt;/isg;
$tabend=~s/</&lt;/isg;
$tabend=~s/>/&gt;/isg;

while (<STDIN>) {
  # identify header, convert to escaped HTML, store
  # also catch first instance of </tr> which belongs to header row
  if (/<th>/i || (m%</tr>%i && $tr++==0)) {
    s/</&lt;/isg;
    s/>/&gt;/isg;
    debug("THUNK: $_");
    $head .= $_;
    next;
  }

  # start of new item, which is also title
  # note that table inside description must be escaped
  # the tr below starts the table row for the data
  s%^<tr><td>(.*?)</td>$%<item><title>$1</title><description>$tabstart$head&lt;tr&gt;%i;

  # end of item
  s%^</tr>$%$tabend</description></item>%i;

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
