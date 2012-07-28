#!/bin/perl

# checks if Flash plugin has crashed, and reloads tutor page if so

require "/usr/local/lib/bclib.pl";

for (;;) {
  debug("ENTERING LOOP");
  $res = system("pgrep plugin|xargs ps -wwwl | fgrep flash > /dev/null");
  debug("RES: $res");
  if ($res) {system("/root/build/firefox/firefox http://tutor.u.94y.info/\?restart");}
  sleep(5);
}
