#!/bin/perl

# Open URLs specified on STDIN/file, waiting 1s between each. Trivial
# wrapper around: egrep -v '^#' /home/barrycarter/se-sites.txt | xargs
# -n 1 -i /root/build/firefox/firefox -remote 'openURL({})'

require "/usr/local/lib/bclib.pl";

# added this to use "best" firefox for brighton and old machine

my($binary, $option);

# TODO: this is hack, I happen to know /bin/firefox exists only on brighton

if (-f "/bin/firefox") {
  $binary = "/bin/firefox";
  $option = "--newt

for $i ("/bin/firefox", "/root/build/firefox/firefox") {
  if (-f $i) {
    $binary = $i;
    last;
  }
}

while (<>) {
  chomp;

  # ignore comments
  if (/^\#/) {next;}

  # TODO: make this path to firefox canonical
  my($out,$err,$res) = cache_command2("$binary -remote 'openURL($_)'");
  # TODO: make sleep time an option
  sleep(2);
}
