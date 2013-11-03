#!/bin/perl

# splinters from bc-get-weather.pl to provide astronomical information
# for X window background (bc-bg.pl) for next minute (to avoid 1m
# lag), and schedules <h>(pron. say-joules)</h> at job to call itself
# again when needed; unlike bc-get-weather.pl, uses Astro::Nova and
# does better job with moon rise/set

# --latitude: use this latitude (default: Albuquerque)
# --longitude: use this longitude (default: Albuquerque)
# --time: use this time (in Unix seconds) (default: current time)

require "/usr/local/lib/bclib.pl";

# determine next minute
$time = $globopts{time} || time();
my($nm) = 60*floor($time/60)+60;
# in military time
$now = strftime("%H%M", localtime($nm));

# lat/long
defaults("longitude=-106.651138463684&latitude=35.0844869067959");
my($lng, $lat) = ($globopts{longitude}, $globopts{latitude});

# lunar phase experiments below
# my($observer) = Astro::Nova::LnLatPosn->new("lng"=>$lon,"lat"=>$lat);
my($jd) = get_julian_from_timet($time);

for $i (0..30) {
  my($foo) = $jd+$i-64/1440;
  $foo  = $jd + 13.5 + 13/30 + 2*$i/900;
  print join("\t", $i, Astro::Nova::get_lunar_bright_limb($foo),
	     Astro::Nova::get_lunar_phase($foo)),"\n";
}

die "TRESTING";




# current info (for next minute)
%sm = sunmooninfo($lng,$lat,$nm);

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
if ($moonup) {$str2 = "MOON UP";} else {$str2 = "MOON DOWN";}

# solar elevation in degrees/minutes
$el = sprintf("(%s%d\xB0%0.2d'%0.2d'') (%0.4f)", dec2deg($sm{sun}{alt}), $sm{sun}{alt});

# +30 for rounding, convert times to military time
map($_=strftime("%H%M",localtime($_+30)), @times);

print "$str $el ($now)\n";
# sun rise + various twilights
print "S:$times[6]-$times[7] ($times[4]-$times[5]/$times[2]-$times[3]/$times[0]-$times[1])\n";
print "M:$times[8]-$times[9] ($str2)\n";
