#!/bin/perl

# youtube-dl will download past twitch.tv videos (with possibly some
# limitations)-- this script finds videos for channels I follow and
# lists them in reverse order (more recent videos are probably more
# interesting AND twitch may not allow simple dls of videos over 14
# days old)

# TODO: check that I don't already have video in ~/MP4/TWITCH/

require "/usr/local/lib/bclib.pl";

for $i (split(/\n/, read_file("/home/user/my-twitch-channels.txt"))) {

  if ($i=~/^\s*$/ || $i=~/^\#/) {next;}

  # dl the all videos page, like:
  # https://www.twitch.tv/barrycarter2019/videos?filter=all&sort=time

  my($url) = "https://www.twitch.tv/$i/videos?filter=all&sort=time";

  debug("URL: $url");

  # cache for one day, put into dir so I can look at them

#  my($out, $err, $res) = cache_command2("curl -o /var/cache/twitch/$i.html -L '$url'", "age=86400");
  
  debug($out);

  die "TESTING";

}


