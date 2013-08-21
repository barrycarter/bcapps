#!/bin/perl

# given a commentid, find what page (eg,
# http://www.gocomics.com/comments/page/120318) it is on; useful to
# complete my collection of gocomics comments

# NOTE: a given comment's page number increases as new comments come in

require "/usr/local/lib/bclib.pl";

# find initial slope (TODO: put this in loop?)
@p1=get_page_comments(1);
@p2=get_page_comments(2);
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
    debug("PAGE: $page, GOAL: $i, SLOPE: $slope, MEDIAN($page): $median{$page}");
    my($guess) = int($page + ($median{$page}-$i)/$slope);
    debug("NEW GUESS: $guess");
    # if guess is same as page, we have found page for this commentid
    if ($guess == $page) {$location{$i} = $guess; last;}
    my(@guessids) = get_page_comments($guess);
    my($median) = median(\@guessids);
    $median{$guess} = $median;
    # new slope guess
    $slope = -($median{$page}-$median)/($page-$guess);
    # new page is now current page
    $page = $guess;
  }
}

for $i (sort keys %location) {
  print "$i -> $location{$i}\n";
}

# given a gocomics comments page number, return list of ids on that page
sub get_page_comments {
  my($page) = @_;
  my(%ids);
  my($out,$err,$res) = cache_command2("curl -H 'Accept: text/html' -A 'Fauxzilla' http://www.gocomics.com/comments/page/$page","age=3600");
  while ($out=~s/comment_(\d+)//) {$ids{$1}=1;}
  return sort keys %ids;
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
