#!/bin/perl

# silly prog to generate ansi color, etc sequences

%CODES=(
0,"All*attributes*OFF",
1,"Bold*ON",
4,"Underscore*ON",
5,"Blink*ON",
7,"Reverse*Video*ON",
8,"Concealed*ON",
30,"Black*FG",
31,"Red*FG",
32,"Green*FG",
33,"Yellow*FG",
34,"Blue*FG",
35,"Magenta*FG",
36,"Cyan*FG",
37,"White*FG",
40,"Black*BG",
41,"Red*BG",
42,"Green*BG",
43,"Yellow*BG",
44,"Blue*BG",
45,"Magenta*BG",
46,"Cyan*BG",
47,"White*BG",
"","nothing"
);


# bit string: (under)(blink)(revvid)(conceal)(fg-col)(fg-bold)(bg-col)(bg-bold)

for (;;) {
  $m++;
  $n=$m;
  @a=();
  if ($n&1==1) {push(@a,4);} # underscore
  $n>>=1;
  if ($n&1==1) {push(@a,5);} # blink
  $n>>=1;
  if ($n&1==1) {push(@a,7);} # revvid
  $n>>=1;
  if ($n&1==1) {push(@a,8);} # conceal
  $n>>=1;
  
  if ($n&1==1) {push(@a,1);} # fg bold
  $n>>=1;
  push(@a,30+($n&7)); # fg col
  $n>>=3;

  if ($n&1==1) {push(@a,1);} # bg bold
  $n>>=1;
  push(@a,40+($n&7)); # bg col
  $n>>=3;

  # if conditions below are met, back at 0 state
  if ($a[0]==30 && $a[1]==40 && $#a==1) {exit;}

  @b=();
  for $i (@a) {push(@b,$CODES{$i});}

  $str=join(";",@a);
  $pri=join(", ",@b);
  
  print "\e[${str}mThis line ($m) has the following codes: $pri\e[0m\n";
}

