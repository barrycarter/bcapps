#!/bin/perl

# mediawiki stuff to keep things updated (ie, delete pages remotely
# that no longer exist locally)

require "/usr/local/lib/bclib.pl";

@pages = mediawiki_list_pages("http://peanuts.referata.com/w/api.php");

# these changes are just so I can compare disk files to mediawiki page names
for $i (@pages) {
  $i=~s/\xef\xbc\x83/&\#65283\;/g;
  $i=~s/&\#039\;/&\#39\;/g;
}

print join("\n", @pages),"\n";

=item mediawiki_list_pages($apiep, $ns=0)

Given a wiki API endpoint and a namespace (default 0), return a list
of all pages in wikis namespace.

=cut

sub mediawiki_list_pages {
  my($apiep, $ns) = @_;
  my($gapfrom) = "";
  my(@pages); # for the result
  unless ($ns) {$ns=0;}

  # the "ungapped" URL
  my($url) = "$apiep?action=query&generator=allpages&gaplimit=500&prop=revisions&rvprop=timestamp|user&format=xml&namespace=$ns";

  for (;;) {
    # 3600 below is arbitrary
    my($out, $err, $res) = cache_command2("curl -s -m 300 '$url&gapfrom=$gapfrom'","age=3600");
    while ($out=~s/title="(.*?)">//s) {
      push(@pages, $1);
    }
    # end of page list?
    unless ($out =~ /<allpages gapcontinue="(.*?)"/) {last;}
    $gapfrom = urlencode($1);
  }
  return @pages;
}


