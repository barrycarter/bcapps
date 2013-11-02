#!/bin/perl

# splinters from bc-get-weather.pl to provide astronomical information
# for X window background (bc-bg.pl) for next minute (to avoid 1m
# lag), and schedules <h>(pron. say-joules)</h> at job to call itself
# again when needed; unlike bc-get-weather.pl, uses Astro::Nova and
# does better job with moon rise/set

require "/usr/local/lib/bclib.pl";

# my approximate latitude/longitude (if you type this into google
# maps, you get an address; to emphasize, I do NOT live at that
# address!)

# TODO: let this be an option to the program?
my($lng,$lat) = (-106.55, 35.1);

# determine next minute
my($nm) = 60*floor(time()/60)+60;

%sm = sunmooninfo($lng,$lat,$nm);

# if the sun is above -6 degrees, we want start/end of "current"
# twilight; otherwise, start/end of next twilight; same for naut/astro

# TODO: this is inefficient, because I build the observer object
# multiple times

# altitudes for twilights
%alts = ("astro" => -18, "naut" => -12, "civ" => -6, "sun" => -5/6);

for $i ("astro", "naut", "civ", "sun") {
  if ($sm{sun}{alt} >= $alts{$i}) {
    # if we are in this/higher state, give previous "rise", next "set"
    push(@times, np_rise_set($lng, $lat, $nm, $i, "rise", -1));
    push(@times, np_rise_set($lng, $lat, $nm, $i, "set", +1));
    # $cur will be highest state we've reached, empty for night
    $cur = $i;
  } else {
    # not in this state? give next rise/set
    push(@times, np_rise_set($lng, $lat, $nm, $i, "rise", -1));
    # TODO: un-redundant line below
    push(@times, np_rise_set($lng, $lat, $nm, $i, "set", +1));
  }
}

# and moon
if ($sm{moon}{alt} >= 0.125) {
  # moon is up, give previous rise (always give next set)
  push(@moon, np_rise_set($lng, $lat, $nm, "moon", "rise", -1));
  $moonup = 1;
} else {
  # give next rise
  push(@moon, np_rise_set($lng, $lat, $nm, "moon", "rise", +1));
}

# always give next set
push(@moon, np_rise_set($lng, $lat, $nm, "moon", "set", +1));

debug("$moonup/",@moon);
debug("CUR: $cur");

for $i (@times) {
  # +30 for rounding
  debug(strftime("%H:%M", localtime($i+30)));
}

debug(unfold(%sm));


