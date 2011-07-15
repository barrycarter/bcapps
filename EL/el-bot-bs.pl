#!/bin/perl

# Creates an SQLite3 db of what bots are buying and selling in EL
# TODO: extend beyond el-services.net

require "bclib.pl";

# list of all bots
($res) = cache_command("curl http://bots.el-services.net/", "age=3600");

# bot name
while ($res=~s/<a class="arrow" href="(.*?)">//) {
  push(@bots, $1);
}

for $i (@bots) {
  debug("BOT: $i");
  # TODO: parallelize?
  # grab bot's page
  ($res) = cache_command("curl http://bots.el-services.net/$i", "age=3600");

  # find bot location (ugly)
  $res=~s%<tr class="botinfo-location"><td class="botinfo-leftmargin"></td><td class="botinfo-location" colspan="2">(.*?)</td></tr>%%is;
  $loc = $1;
  # break into map, coords
  $loc=~/^\s*(.*?)\s*\[(\d+\s*\,\d+)\]/;
  # below is ugly
  $loc=~s/\'//isg;
  ($map, $coord) = ($1,$2);
  ($x, $y) = split(/\,\s*/, $coord);
  # avoid blanks, which confuse sqlite3
  unless ($x) {$x=0;}
  unless ($y) {$y=0;}

  push(@queries, "REPLACE INTO bots (bot, map, x, y) VALUES ('$i', '$map', $x, $y)");

  # replace this bots items
  push(@queries, "DELETE FROM items WHERE bot='$i'");

  # find the selling section (ugly)
  $res=~s/<div id="selling">(.*?)<div id="purchasing">//s;
  ($sell, $buy) = ($1, $res);

  # items
  while ($sell=~s%<td class="public2">(.*?)</td>\s*<td class="public_right">(.*?)</td>\s*<td class="public_right">(.*?)</td>%%is) {
    handle_row($1, $2, $3);
    ($item, $quant, $price) = ($1, $2, $3);
    debug("A: $item/$price/$quant");

    # TODO: fix redundancy between this section + buy section
    $item=~s/\'//isg;
    $quant=~s/[^\d]//isg;
    $price=~s/[^\d\.]//isg;
    debug("PRICE BETA: $price");
    $price*=100;
    debug("PRICE GAMMA: $price");


    # TODO: this is really bad, ignoring the most important ones
    # because they don't meet format above
    if ($item=~/no limit/i) {
      warnlocal("SKIPPING: $item/$quant/$price");
      next;
    }

    push(@queries, "INSERT INTO items (bot, buyorsell, item, price, quantity)
                    VALUES ('$i', 'SELL', '$item', $price/100, $quant)");
  }

  while ($res=~s%<td class="public2">(.*?)</td>\s*<td class="public_right">(.*?)</td>\s*<td class="public_right">(.*?)</td>%%is) {
    ($item, $quant, $price) = ($1, $2, $3);

    $item=~s/\'//isg;
    $quant=~s/[^\d]//isg;
    $price=~s/[^\d\.]//isg;
    $price*=100;

    # TODO: this is really bad, ignoring the most important ones
    # because they don't meet format above
    if ($item=~/no limit/i) {
      warnlocal("SKIPPING: $item/$quant/$price");
      next;
    }

    push(@queries, "INSERT INTO items (bot, buyorsell, item, price, quantity)
                    VALUES ('$i', 'BUY', '$item', $price/100, $quant)");
  }
}

# wrap in transaction
unshift(@queries,"BEGIN");
push(@queries,"COMMIT");

# TODO: choose a better tmp file
write_file(join(";\n",@queries).";\n", "/tmp/botqueries.txt");
system("sqlite3 ~/BCINFO/sites/DB/bots.db < /tmp/botqueries.txt");

# Given a buy/sell row regex matches, return item name, price,
# quantity (but not whether its buy/sell, since argument won't tell us
# that)

sub handle_row {
  my($item, $price, $quant) = @_;
  debug("$item/$price/$quant");
}


=item schema

Schema for the bots db:

CREATE TABLE bots (
 bot TEXT,
 map TEXT,
 x INT,
 y INT
);

CREATE UNIQUE INDEX ibot ON bots(bot);

CREATE TABLE items (
 bot TEXT,
 buyorsell TEXT,
 item TEXT,
 price DOUBLE,
 quantity INT
);

=cut

