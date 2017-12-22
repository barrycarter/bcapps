#!/bin/perl

# gave up on YAML, parsing XML instead

require "/usr/local/lib/bclib.pl";
use XML::Simple;

# TODO: use simpler names instead of always referring to hash
# TODO: allow for multiple categories (comma sep)

# TODO: change target dir
# target dir is where each post is written to a file
my($targetdir) = "/home/user/20171218/wp";

# fields I want w/ examples:

# $i->{'title'} = Ricky Gervais (reliable source)
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

# debug(var_dump("DATA",$data));
# die "TESTNG";

for $i (@{$data->{channel}->{item}}) {

  # only published posts for now (no pages, etc)
  unless ($i->{'wp:post_type'} eq "post") {next;}

  # special case just to see privates (ha ha)
  if ($i->{"wp:status"} eq "private") {
    debug("PRIVATE: $i->{title}");
  }

  unless ($i->{"wp:status"} eq "publish") {next;}

  # some variable cleanup
  my(@cat, $cat) = ();

  if (ref($i->{category}) eq "ARRAY") {
    for $j (@{$i->{category}}) {
      push(@cat, $j->{nicename});
    }
    $cat = join(", ", @cat);
  } else {
    $cat = $i->{'category'}->{'nicename'};
  }

  # it turns out dc:creator can do this too
  # TODO: if this happens frequently, subroutinize
  
  my(@aut, $aut) = ();

  if (ref($i->{'dc:creator'}) eq "HASH") {
    debug("CREATOR IS HASH", $i->{'dc:creator'});
    debug(var_dump("creator", $i->{'dc:creator'}));

    # TODO: empty hash? temporarily just assinging auth to nothing
    $aut = "";

#    for $j (@{$i->{'dc:creator'}}) {
#      push(@aut, $j);
#    }
#    $aut = join(", ", @aut);
  } else {
    $aut = $i->{'dc:creator'};
  }


  debug(var_dump("I",$i));

  debug("AUTH:". $i->{'dc:creator'});

$str = << "MARK";

ID: $i->{'wp:post_id'}
post_name: $i->{'wp:post_name'}
post_category: $cat
post_author: $aut
post_date_gmt: $i->{'pubDate'}
post_type: $i->{'wp:post_type'} 
post_status: $i->{'wp:status'}
post_title: $i->{title}

======================================================

$i->{'content:encoded'}

MARK
;

debug("STR is $str");

open(A, ">$targetdir/$i->{'wp:post_name'}.wp");
print A $str;
close(A);
  
}
