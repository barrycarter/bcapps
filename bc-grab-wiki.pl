#!/bin/perl

# suck down a wiki and maintain it efficiently using MediaWiki api.php
# TODO: check for </api> at end of pages to ensure complete load

require "bclib.pl";
# where I store my wikis
$wikiroot = "/usr/local/etc/wiki";

grab_all($ARGV[0]);

=item grab_all($wiki)

Thin wrapper around grab() that grabs all $wiki's pages, all namespaces

=cut

sub grab_all {
  my($wiki) = @_;

  # create the wiki dir (+ images subdir) and cd to wikidir
  # uc() below is to canonicalize wiki
  my($wikidir) = "/usr/local/etc/wiki/".uc($wiki);
  # mkdir -p creates $wikidir too
  system("mkdir -p $wikidir/images");
  chdir($wikidir)||die("Can't chdir($wikidir), $!");

  for $i (namespaces($wiki)) {
    debug("NAMESPACE: $i");
    grab($wiki,$i);
  }
}

=item grab($wiki,$ns=0)

Grabs all $wiki's namespace $ns pages. Returns list of names of pages
updated (pages that are already current are NOT returned)

=cut

sub grab {
  my($wiki, $ns) = @_;
  unless ($ns) {$ns=0;}
  my(@result);

  # get info on the first 500 pages
  my($url) = "http://$wiki/api.php?action=query&generator=allpages&gaplimit=500&prop=revisions&rvprop=timestamp|user&format=xml&gapnamespace=$ns";
  # NOTE: setting age= semi-arbitrarily for now
  my($res)=cache_command("curl -s -m 300 '$url'","age=3600&retfile=1");
  my(@res) = ($res); # the files that hold list of pages

  # find the continuation point, repeat until done
  for (;;) {
    my($all) = read_file($res);
    # end of page list? 
    unless ($all =~ /<allpages gapfrom="(.*?)"/) {last;}
    my($gapfrom) = urlencode($1);
    debug("PAGE: $gapfrom");
    # not end of page list, so grab more pages (names only)
    $res = cache_command("curl -s -m 300 '$url&gapfrom=$gapfrom'","age=3600&retfile=1");
    push(@res,$res);
  }

  # see if I have latest version of all listed pages
  # record info for each page regardless

  open(A,">pageinfo-$ns.txt");
  for $i (@res) {

    my($all) = read_file($i);
    my(@pages) = ($all =~m%(<page.*?</page>)%isg);

    for $j (@pages) {

      # cheating below and using timestamp as revid
      $j=~/title="(.*?)".*timestamp="(.*?)"/||warnlocal("BAD PAGE DATA: $j");
      my($title,$revid,$hash) = ($1,$2,sha1_hex($1));
      $revid=~s/T/./;
      $revid=~s/[^\d\.]//isg;

      # latest revision wiki has (from its pagelist)
      print A substr($hash,0,2)."/$hash $revid\t$title\n";
      # latest revision I have
      my($rev) = get_timestamp($wiki,$title);

      # if not equal, grab page and push page onto results
      unless ($rev == $revid) {
	debug("REV: $rev, REVID: $revid");
	get_page($wiki,$title);
	push(@result,$title);
      }
    }
  }

  close(A);
  return(@result);
}

=item get_page($wiki,$page)

Obtain $page from $wiki, store in sha1 hex of $page name (not
content). To avoid too many files in one directory, store in "xx/sha1"
where xx = first two letters of sha1

NOTE: storing in sha1 hex of content might make sense to keep older verisons.

This function returns nothing.

=cut

sub get_page {
  my($wiki,$page,$timestamp) = @_;

  # where to put $page (create directory if needed)
  my($outfile) = sha1_hex($page);
  # no need to do subdirectories for images, there usually arent many(?)
  my($imagefile) = "images/$outfile";
  my($outdir) = substr($outfile,0,2);
  unless (-d $outdir) {mkdir($outdir);}
  $outfile = "$outdir/$outfile";
  debug("$page -> $outfile");

  # is this page an image?
  my($is_image) = ($page=~/^Image:/);

  # URL encode and grab
  $page = urlencode($page);
  my($url) = "http://$wiki/api.php?action=query&prop=revisions|imageinfo&titles=$page&rvprop=timestamp|content&iiprop=url&format=xml";

  # set timestamp, and keep at least one older version
  $timestamp=~s/t/ /isg; # convert wiki timestamp to touch timestamp
  # no need to cache this: I only call this if I need a newer version
  # NOTE: mv gets whiny if $outfile doesn't exist, so silencing it below
  my($command)= "mv -f $outfile $outfile.bak 1> /dev/null 2> /dev/null; curl -s -m 300 -o $outfile '$url'";
  # NOTE: program was written back when I used system() not cache_command()
  # could change it, but no need ATM
  system($command);

  # grab image if this is an image
  if ($is_image) {
    my($content) = suck($outfile);
    $content=~m%<ii url="(.*?)" />%is||warnlocal("Image page has no image");
    $url = $1;
    $command = "curl -s -m 300 -o $imagefile 'http://$wiki/$url'";
    system($command);
  }
}

=item get_revision($wiki,$page)

Shows which revision (integer) of $wiki's $page I have

=cut

sub get_revision {
  my($wiki,$page) = @_;
  # TODO: this code is very similar to get_timestamp; combine?
  my($hash) = sha1_hex($page);
  $hash = substr($hash,0,2)."/$hash";
  unless (-f $hash) {return 0;}

  my($all)=suck($hash);

  # if </api> doesn't end this file, we've got an incomplete version
  unless ($all=~m%</api>\s*$%is) {
    warnlocal("$page incomplete, treating as revision 0");
    return 0;
  }

  if ($all=~/revid="(.*?)"/) {return $1;}
  warnlocal("$page exists, but has no revision");
  return 0;
}

=item get_timestamp($wiki,$page)

Get the timestamp for my version of $wiki's $page in yyyymmdd.hhmmss
("stardate") GMT format

=cut

sub get_timestamp {
  my($wiki,$page) = @_;
  # TODO: not sure that storing page in SHA1'd filename helps any
  # NOTE: maybe I did this to avoid clustering too many files in a given dir?
  my($hash) = sha1_hex($page);
  # find file; return 0 if no exist
  $hash = join("/",($wikiroot,uc($wiki),substr($hash,0,2),$hash));
  unless (-f $hash) {return 0;}

  # read file
  my($all)=suck($hash);

  # NOTE: when sucking in parallel, sometimes get incomplete files(?)
  # Of course, I'm not using parallel (yet)
  # if </api> doesn't end this file, we've got an incomplete version
  unless ($all=~m%</api>\s*$%is) {
    warnlocal("$page incomplete, treating as revision 0");
    return 0;
  }

  if ($all=~/timestamp="(.*?)"/) {
    my($ts) = $1;
    $ts=~s/T/./;
    $ts=~s/[^\d\.]//isg;
    return $ts;
  }

  warnlocal("$page exists, but has no timestamp, returning 0");
  return 0;
}

=item namespaces($wiki)

Returns $wiki's namespaces

=cut

sub namespaces {
    my($wiki) = @_;
    my(@result);
    my($url) = "$wiki/api.php?action=query&meta=siteinfo&siprop=namespaces&format=xml";
    my($res)=cache_command("curl -s -m 300 '$url'","age=3600");
    @res= ($res=~/<ns id="([^\"]*)"/isg);
    return @res;
}
