#!/bin/perl

# Does what "wget -m" does, with these caveats/goals:
#  URL content is assumed static and never downloaded again
#  Downloaded content IS checked for hrefs
#  Downloads multiple URLs in parallel

# Program name "mmm" is like "yummy".

# More details: http://stackoverflow.com/questions/13092229/cant-resume-wget-mirror-with-no-clobber-c-f-b-unhelpful

# NOTE: initial program to complete mirror of directions4me.org, code
# is site-specific for now (+ uses results of earlier wget -m)

require "/usr/local/lib/bclib.pl";

# the directory where wget -m started the download
# TODO: in the final version, the start location will be a URL
$dir = "/mnt/sshfs/D4M2/D4M/www.directionsforme.org";
$file = "$dir/index.html";
$site = "www.directionsforme.org";

@urls = get_hrefs(read_file($file));

for $i (@urls) {
#  debug("URL: $i");

  # if this url already visited, ignore it, else mark it visited
  if ($visited{$i}) {next;}
  $visited{$i} = 1;

  # check to see if I have this URL locally from wget
  $file = url2file($i);
  debug("FILE: $file");
  warn "TESTING";
  next;

  $all = read_file($file);

  push(@urls, get_hrefs($all));
  debug("LENGTH: $#urls+1");


}

=item get_hrefs($str)

Obtains all hrefs (and srcs) from given string, provided they are on
the same host

=cut

sub get_hrefs {
  my($str) = @_;
  my(%ret);
  # TODO: this assumes well-formed href/src, which many are not
  while ($str=~s/(href|src)=[\"\'](.*?)[\"\']//is) {
    my($url) = $2;

    # if relative (to host), fix
    if ($url=~m%^/%) {$url = "http://$site$url";}

    # canonize URL (after adding $site)
    $url = canonize_url($url);

    # TODO: make this more general
    # ignore images
    if ($url=~/\.(jpg|png)$/) {next;}

    # now fully qualified, if another host, ignore
    $url=~m%^https?://([^/]*?)(/|$)% || warn("BAD URL: $url");
    my($host) = $1;
    unless ($host eq $site) {next;}

    # avoid dupes
    $ret{$url}=1;
  }
  return keys %ret;
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

  # add trailing slash (just one) to URL
  # TODO: copied this from one of my old programs, not sure its valid
  # if ($url=~m!/[^/\.]+$!) {$url="$url/";}

  return $url;
}

=item url2file($url)

Given a URL, look in various locations to see if I have content of
$url stored already. Return file where stored, or nothing if no
such file exists

=cut

sub url2file {
  my($url) = @_;
  debug("URL2FILE($url)");

  # check to see if I have this URL locally from wget
  $file = $i;
  $file=~s%https?://$site/?%$dir/%;

  # if $file happens to be a directory, use $file/index.html (wget convention)
  if (-d $file) {$file = "$file/index.html";}

  if (-f $file) {return $file;}

  return;
}


