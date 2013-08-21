#!/bin/perl

# given a commentid, find what page (eg,
# http://www.gocomics.com/comments/page/120318) it is on; useful to
# complete my collection of gocomics comments

# NOTE: a given comment's page number increases as new comments come in

require "/usr/local/lib/bclib.pl";

# find initial slope (TODO: put this in loop?)
@p1=get_page_comments(1);
@p2=get_page_comments(2);
# debug("P1",@p1,"P2",@p2);
$median{1} = median(\@p1);
$median{2} = median(\@p2);
debug("$median{1} vs $median{2}");

for $i (@ARGV) {
  # initial slope and page (for each comment that we seek)
  $slope = $median{1}-$median{2};
  $page = 1;
  debug("SEARCHING FOR: $i");

  # enter loop to find page
  for (;;) {
    debug("SLOPE/PAGE: $slope/$page/$i");
    my($guess) = int($page + ($median{$page}-$i)/$slope);
    my(@guessids) = get_page_comments($guess);
    debug("GUESS: $guess, IDS:",@guessids);
    die "TESTING"
  }

}

die "TESTING";


for (;;) {
  @ids = ();
  # 3600 is a large cache time, but should be OK
  my($out,$err,$res) = cache_command("curl -A 'Fauxzilla' http://www.gocomics.com/comments/page/$page","age=3600");
  # look at ids and estimate position of $commentid
  while ($out=~s/"id":(\d+)//) {push(@ids,$1);}
  # 25/page, so... (but closer to 30 after deletes)
  $page += ($ids[0]-$commentid)/30;
  $page = int($page);
  debug("NEW PAGE: $page");
}

# given a gocomics comments page number, return list of ids on that page
sub get_page_comments {
  my($page) = @_;
  my(@ids);
  my($out,$err,$res) = cache_command2("curl -H 'Accept: text/html' -A 'Fauxzilla' http://www.gocomics.com/comments/page/$page","age=3600");
  while ($out=~s/comment_(\d+)//) {push(@ids,$1);}
  return @ids;
}

# TODO: add me to bclib.pl

=item median(\@list, $options)

Return the median of @list

$options currently unused [add option for incoming list already sorted]

=cut

sub median {
  # TODO: add 
  my($listref) = @_;
  my(@list) = @{$listref};

  # assume unsorted
  @list = sort(@list);

  # count how many elements in list
  my($elts) = $#list+1;
  debug("ELTS: $elts");
  # if odd, return middle element
  if ($elts%2==1) {return $list[$#list/2];}
  # return the average of the two middle elements
  return ($list[($#list-1)/2] + $list[($#list+1)/2])/2
}
