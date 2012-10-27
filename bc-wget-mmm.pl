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

$all = read_file($file);
debug("DONE READING FILE");

debug(get_hrefs($all));

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
    debug("URL: $url");

    # TODO: make this more general
    # ignore images
    if ($url=~/\.(jpg|png)$/) {next;}

    # if relative (to host), fix
    if ($url=~m%^/%) {$url = "http://$site$url";}

    # now fully qualified, if another host, ignore
    $url=~m%^https?://([^/]*?)(/|$)% || warn("BAD URL: $url");
    my($host) = $1;
    debug("HOST: $host");
    unless ($host eq $site) {next;}

    # avoid dupes
    $ret{$url}=1;
  }
  return keys %ret;
}
