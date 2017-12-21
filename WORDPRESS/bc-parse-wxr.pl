#!/bin/perl

# gave up on YAML, parsing XML instead

require "/usr/local/lib/bclib.pl";
use XML::Simple;


# fields I want w/ examples:

# $i->{'category'}->{'nicename'} = 'humor-attempted';
# $i->{'dc:creator'} = 'barrycarter';
# $i->{'pubDate'} = 'Tue, 18 Dec 2012 00:16:24 +0000';
# $i->{'wp:post_id'} = '25655';
# $i->{'wp:post_name'} = 'we-are-stupid-stars';
# $i->{'wp:post_type'} = 'post';
# $i->{'wp:status'} = 'publish';
# $i->{'content:encoded'}

$xml = new XML::Simple;
$data = $xml->XMLin($ARGV[0]);

for $i (@{$data->{channel}->{item}}) {

  # ignore attachments (for now)
#  if ($i->{"wp:post_type"} eq "attachment") {next;}

  # and unpublished
  unless ($i->{"wp:status"} eq "publish") {next;}

  # only posts and pages for now
  unless ($i->{'wp:post_type'} eq "post" || $i->{'wp:post_type'} eq "page") {
    next;}
  

#   debug("RAW", $i->{'content:encoded'}, "/RAW");

#   next;

#   debug("KEYS", keys %{$i->{'content:encoded'}}, "/kEYS");

#   next;

#   debug("CONTENT",var_dump("content", $i->{'content:encoded'}));

#   next;

#   debug("CONTENT","$i->{'content:encoded'}","/CONTENT");

#   debug("<I>",var_dump("I", $i),"</I>");

#   next;

$str = << "MARK";

ID: $i->{'wp:post_id'}
Slug: $i->{'wp:post_name'}
Category: $i->{'category'}->{'nicename'}
Author: $i->{'dc:creator'}
Date: $i->{'pubDate'}
Type: $i->{'wp:post_type'} 
Status: $i->{'wp:status'}

======================================================
$i->{'content:encoded'}

MARK
;

debug("STR: $str");
  
}
