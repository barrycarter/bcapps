#!/bin/perl

# checks if Flash plugin has crashed, and reloads tutor page if so

for (;;) {
  $res = system("pgrep plugin");
  if ($res) {system("/root/build/firefox/firefox http://tutor.u.94y.info/\?restart");}
  sleep(5);
}
