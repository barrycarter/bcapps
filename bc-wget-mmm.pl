#!/bin/perl

# Does what "wget -m" does, with these caveats/goals:
#  URL content is assumed static and never downloaded again
#  Downloaded content IS checked for hrefs
#  Downloads multiple URLs in parallel

# TODO: get rid of mailto URLs

# Program name "mmm" is like "yummy".

# More details: http://stackoverflow.com/questions/13092229/cant-resume-wget-mirror-with-no-clobber-c-f-b-unhelpful

# NOTE: initial program to complete mirror of directions4me.org, code
# is site-specific for now (+ uses results of earlier wget -m)

require "/usr/local/lib/bclib.pl";

# TODO: turn all of the below into command line options
# list of initial URLs
my(@list) = ("http://www.directionsforme.org");
# all visited URLs must meet this regex
my($regexp) = "directionsforme";
# ignore URLs meeting this regex, even if they match $regex
# special case: if empty, ignore nothing
my($ignore) = "";
# target directory
my($target) = "/mnt/sshfs/D4M3";
# do all work in target
dodie("chdir('$target')");

# write out URL map + URL to sha1 conversions
open(A,">index.txt");
open(B,">hrefs.txt");
open(C,">list.txt");

# next two are temporary should not appear in final version
open(D,">moves.txt");
open(E,">wanted.txt");

while ($i = shift(@list)) {

  # canonize this URL
  $i = canonize_url($i);

  # if this url already visited, ignore it, else mark it visited
  # we may not have really visited this URL, just ignored it, but still works
  if ($visited{$i}) {
    debug("SKIPPING, ALREADY SEEN: $i");
    next;
  }
  $visited{$i} = 1;

  if ($regexp && $i!~m!$regexp!) {
    debug("SKIPPING, FAILS REGEX: $i");
    next;
  }

  if ($ignore && $i=~m!$ignore!) {
    debug("SKIPPING, MEETS IGNORE REGEX: $i");
    next;
  }

  my($res) = url2file($i);

  unless ($res) {
    print E "$i\n";
    warn "SKIPPING DURING TESTING ONLY";
    next;
  }

  # note where URL is stored
  print A "$res $i\n";

  @newurls = get_hrefs(read_file($res),$i);

  for $j (@newurls) {
    # canonize the URL
    $j = canonize_url($j);

    # exclude URLs that fail regex (dont HAVE to do this here, but it
    # helps keep list shorter)
    if ($regexp && $j!~m!$regexp!) {next;}
    if ($ignore && $j=~m!$ignore!) {next;}

    # if already visited URL (or its on the to-visit list), dont readd
    if ($added{$j}||$visited{$j}) {next;}

    # add it and mark it "added"
    print B "$i $j\n";
    print C "$j\n";
    debug("ADDED: $j");
    push(@list,$j);
    $added{$j}=1;
  }
}

close(A);
close(B);
close(C);

=item get_hrefs($str,$url)

Obtains all hrefs (and srcs) from given string, assuming the hrefs
came from $url (used to fix relative paths)

=cut

sub get_hrefs {
  my($str,$url) = @_;
  my(@res);

  # get hostname
  $url=~m!(https?://.*?)($|/)!||warn("NOHOSTNAME: $url");
  my($hostname)=$1;
  $url=~m!^(.*/)[^/]*$!||warn("NODIRNAME: $url");
  my($dirname)=$1;

  # find all HTML tags, and store those with href/src
  my(@tags)= ($str=~/<(.*?)>/isg);
  my(%hrefs);
  for $i (@tags) {
    # use hash to avoid dupes
    if ($i=~/(href|src)=[\"\']?(.*?)[\"\']?($|\s)/is) {$hrefs{$2}=1;}
  }

  # go through hrefs and turn them into complete URLs
  for $i (keys %hrefs) {
    # ignore empty URLS
    # TODO: is this the right behavior here?
    if ($i=~/^\s*$/) {next;}

    if ($i=~m!^[a-z]+:!) {
      # do nothing; leave "protocol:something" as is
    }  elsif ($i=~m!^/!) {
      # starts with /, just add hostname
      $i="$hostname$i";
    } else {
      # doesnt start with /, so append to $dirname
      $i="$dirname$i";
    }

    # always canonize
    $i = canonize_url($i);
    push(@res,$i);
  }
  return @res;
}

=item canonize_url($url)

Given a fully qualified URL, canonize it by:

  - Removing trailing slashes (http://example.com////)
  - Changing foo/../bar to foo/bar
  - Removing virtual directory sorting options
  - Removing #location

=cut

sub canonize_url {
  my($url) = @_;

  # kill off #position
  $url=~s/\#.*$//isg;

  # fix foo/../ but without fixing http://bar.com/..
  while ($url=~s!/[^/\.]+/\.\./!/!isg) {}

  # remove virtual directory sorting options
  $url=~s!/\?[NMSD]\=[AD]/*!!isg;

  # remove trailing slash(es)
  # TODO: is this bad?
  $url=~s!/+$!!;

  return $url;
}

=item url2file($url)

Given a URL, look in various locations to see if I have content of
$url stored already. Return file where stored, or nothing if no
such file exists

=cut

sub url2file {
  my($url) = @_;
  my($sha,$file);
  # URLs should be canonized before calling this sub, but just in case
  $url = canonize_url($url);

  # using two directory level sha1 (ie xx/xx/sha)
  $sha = sha1_hex($url);
  $sha=~/^(..)(..)/;
  $file = "$1/$2/$sha";

  if (-f $file) {return $file;}

  # TODO: check for </html> or something?

  # due to (yet another) error, I hashed http://./URL instead
  # move it to correct place then return
  my($url2) = $url;
  $url2=~s%http://%http://./%;
  my($sha2) = sha1_hex($url2);
  $sha2=~/^(..)(..)/;
  my($file2) = "$1/$2/$sha2";

  print D "mv $file $file2\n";

  if (-f $file2) {return $file2;}

  debug("URL NOT FOUND: $url");

  return;
}


