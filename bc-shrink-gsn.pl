#!/bin/perl

# Shrinks the GSN schedule
# (http://www.gsn.com/cgi/onair/program_schedule_print.html) to print
# on fewer pages

# This is another one off that helps only me, with the slight
# possibility it won't even help me

require "/usr/local/lib/bclib.pl";

# Idea is to create our own array from table, abbreviate, and print that

$all = read_file("/home/barrycarter/BCGIT/db/program_schedule_print.html");

# rows
while ($all=~s%<tr>(.*?)</tr>%%is) {
  push(@rows, $1);
}

for $i (@rows) {
  # break into cells
  @cells = ();
  while ($i=~s%<td[^>]*?>(.*?)</td>%%is) {
    push(@cells, $1);
  }

  # first cell is timing info
  $time = shift(@cells);

  for $j (@cells) {
    # remove HTML
    $j=~s/<.*?>//isg;

    # remove newlines
    $j=~s/\s+/ /isg;

    # preserve parentheses for these (multiple hosts)
    $j=~s/family feud/FF/isg;
    $j=~s/^.*newlywed game/NG/isg;
    $j=~s/match game/MG/isg;
    $j=~s/^.*pyramid/PMD/isg;

    # do not preserve parens (single host or paren info useless)
    $j=~s/^.*deal or no deal.*$/DOND/isg;
    $j=~s/^.*paid programming.*$/--/isg;
    $j=~s/^.*password.*$/PW/isg;
    $j=~s/^.*press your luck.*$/W!/isg;
    $j=~s/^.*jeopardy.*$/J!/isg;
    $j=~s/^.*lingo.*$/LNG/isg;
    $j=~s/^.*press your luck.*$/W!/isg;
    $j=~s/^.*catch 21.*$/C21/isg;
    $j=~s/^.*millionaire.*$/M\$/isg;
    $j=~s/^.*1 vs 100.*$/1V100/isg;

    $j=trim($j);

  }

  debug("CELLS",@cells);
}
