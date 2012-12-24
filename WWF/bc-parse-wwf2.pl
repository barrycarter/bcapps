#!/bin/perl

# a completely different approach to parsing games that may or may not
# be simpler than bc-parse-wwf.pl

require "/usr/local/lib/bclib.pl";

$filespec = "/mnt/sshfs/WWF/wwf*.html";

# TODO: really need to start getting rid of some files once game is
# complete... I tend to save files FREQUENTLY

# list of all games (the 'cut' is admittedly silly)
@games = `grep -h '<a href="#" data-game-id=' $filespec | sort | uniq | cut -d '"' -f 4`;

# games on which I have extended info
# below, cut must come before sort/uniq, since class="foo" changes
@extra = `egrep -h 'id="game_[0-9]+"' $filespec | cut -d '"' -f 2 | sort | uniq`;

# find file order using data in file (not mtime, since that can get mangled)
# the 'cut' below is admiteddly gratuitous
@times = `grep timeago $filespec | cut -d '"' -f 1,6 | sort`;

for $i (@times) {
#  chomp($i);
#  debug("I: $i");
  # this works because input is sorted
  # the '"?' below is solely to make emacs happy, there is never an end quote
  $i=~/^(.*?):.*?class="(.*?)"?$/;
  $time{$1} = $2;
}

@files = sort {$time{$b} cmp $time{$a}} keys %time;

for $i (@files) {
  debug("$i -> $time{$i}");
}
