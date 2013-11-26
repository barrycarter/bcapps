#!/bin/perl

# splinters from bc-get-weather.pl to provide astronomical information
# for X window background (bc-bg.pl) for next minute (to avoid 1m
# lag), and schedules <h>(pron. say-joules)</h> at job to call itself
# again when needed; unlike bc-get-weather.pl, uses Astro::Nova and
# does better job with moon rise/set

# --latitude: use this latitude (default: Albuquerque)
# --longitude: use this longitude (default: Albuquerque)
# --time: use this time (in Unix seconds) (default: current time)
# --noprint: do not print to info file (useful for testing)

require "/usr/local/lib/bclib.pl";

# lat/long
defaults("longitude=-106.651138463684&latitude=35.0844869067959");
my($lng, $lat) = ($globopts{longitude}, $globopts{latitude});

# determine next minute and compute for MIDDLE of that minute
$time = $globopts{time} || time();
my($nm) = 60*floor($time/60)+90;
# in military time
$now = strftime("%H%M%S", localtime($nm));

my($mage, $nphase, $tnphase) = mooninfo($nm);
$nphase = ("NM", "FQ", "FM", "LQ", "NM")[$nphase];
# thing to print after moon phase
# TODO: this is ugly way to force sign printing
if ($tnphase > 0) {
  $mprint = sprintf("%0.2fd;$nphase+%0.2fd", $mage, $tnphase);
} else {
  $mprint = sprintf("%0.2fd;$nphase-%0.2fd", $mage, $tnphase);
}

# current info (for next minute)
%sm = sunmooninfo($lng,$lat,$nm);
my($sid) = $sm{sidereal_time};
my($sidp) = sprintf("LST: %dh%0.2dm", $sid, ($sid*60+.5)%60);

# determine moon phase from return info
$phase = ("NEW", "CRES", "QUAR", "GIBB", "FULL")[$sm{moon}{phase}/36];
# these are fly codes for up and down arrow
if ($sm{moon}{dir}>0) {$mdir="\x5e"} else {$mdir="\xb7";}

# determine closest lunar image for urc.gif (upper right hand corner)
# if moon is waning, use 360-phase
my($mimage) = $sm{moon}{phase};
unless ($sm{moon}{dir}) {$mimage = 360-$mimage;}
# round to nearest even degree and fill to three places
$file = sprintf("/home/barrycarter/BCGIT/images/MOON/m%0.3d.gif",round($mimage/2)*2);
debug("FILE: $file");
# copying each time here seems really really inefficient
system("cp -f $file /home/barrycarter/ERR/urc.gif");

# altitudes for twilights (-5/6 for parallax/refraction)
%alts = ("astronomical"=>-18,"nautical"=>-12,"civil"=>-6,"sun"=>-5/6);

# determine if we're in various twilights and whether sun is up;
# if we are in a twilight (including sun up), give start/end time;
# otherwise, give next day start/end time

# TODO: this is inefficient, because I build the observer object
# multiple times

# order is important below to set $cur correctly
for $i (sort {$alts{$a} <=> $alts{$b}} keys %alts) {
  if ($sm{sun}{alt} >= $alts{$i}) {
    # if we are in this/higher state, give previous "rise"
    push(@times, np_rise_set($lng, $lat, $nm, $i, "rise", -1));
    # $cur will be highest state we've reached, empty for night
    $cur = $i;
  } else {
    # not in this state? give next rise/set
    push(@times, np_rise_set($lng, $lat, $nm, $i, "rise", 1));
  }

  # always give next "set"
  push(@times, np_rise_set($lng, $lat, $nm, $i, "set", +1));
}

# and moon (0.125 due to parallax + refraction)
if ($sm{moon}{alt} >= 0.125) {
  # moon is up, give previous rise (always give next set)
  push(@times, np_rise_set($lng, $lat, $nm, "moon", "rise", -1));
  $moonup = 1;
} else {
  # give next rise
  push(@times, np_rise_set($lng, $lat, $nm, "moon", "rise", +1));
}

# always give next set
push(@times, np_rise_set($lng, $lat, $nm, "moon", "set", +1));

# TODO: really cleanup section where I print stuff, ugly coding right now

# what to print in terms of sun/twilight
if ($cur eq "sun") {
  $str = "DAYTIME";
} elsif ($cur eq "") {
  $str = "NIGHT";
} else {
  $str = uc($cur)." TWILIGHT";
}

# moon up or down?
if ($moonup) {$str2 = "UP";} else {$str2 = "DOWN";}

# solar elevation in degrees/minutes
# $el = sprintf("(%s%d\xB0%0.2d'%0.2d'') (%0.4f)", dec2deg($sm{sun}{alt}), $sm{sun}{alt});
$el = sprintf("(%s%d\xB0%0.2d'%0.2d'')", dec2deg($sm{sun}{alt}));

# +30 for rounding, convert times to military time
map($_=strftime("%H%M",localtime($_+30)), @times);

# mostly testing
unless ($sm{moon}{dir}) {$sm{moon}{phase}*=-1;}
my($moondeg) = sprintf("%s%d\xB0%0.2d'%0.2d''", dec2deg($sm{moon}{phase}));

$writestr = << "MARK";
$str $el ($now)
S:$times[6]-$times[7] ($times[4]-$times[5]/$times[2]-$times[3]/$times[0]-$times[1])
M:$times[8]-$times[9] ($str2)
$sidp
$mdir$phase ($mprint) [$moondeg]
MARK
;

unless ($globopts{noprint}) {
  write_file_new($writestr, "/home/barrycarter/ERR/bcgetastro.inf");
}
