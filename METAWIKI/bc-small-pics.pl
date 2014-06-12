#!/bin/perl

# Creates Mediawiki:* pages on
# http://pearls-before-swine-bc.wikia.com/ to display small (300
# width) images when doing <verbatim>yyyy-mm-dd</verbatim> on any page

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

# testing

# unhappy w code duplication here...
# links to high-res version of each strip
# more.txt is a hack to get new strips
# for $i (split(/\n/, read_file("/home/barrycarter/BCGIT/METAWIKI/largeimagelinks.txt"))) {
for $i (split(/\n/, read_file("/tmp/more.txt"))) {
  $i=~s/^(.*?)\s+(.*)1500$//||warn("BAD LINE: $i");
  $link{$1}="${2}300";
}

for $i (sort keys %link) {
  debug("$i: $link{$i}");
  write_wiki_page("http://pearls-before-swine-bc.wikia.com/api.php", "Mediawiki:$i", "<img src='$link{$i}' />", "$i strip (low resolution/fair use)", $wikia{user}, $wikia{pass});
}



