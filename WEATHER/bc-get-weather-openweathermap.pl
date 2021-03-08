#!/bin/perl

# As AERIS stops giving free API data, moving to openweathermap.org

require "/usr/local/lib/bclib.pl";
require "$bclib{home}/bc-private.pl";

# cache during testing only

if ($globopts{test}) {$age=3600;} else {$age=-1;}

my($out, $err, $res) = cache_command2("curl 'https://api.openweathermap.org/data/2.5/onecall?lat=$bclib{latitude}&lon=$bclib{longitude}&appid=$bclib{openweathermap}{appid}&units=imperial'", "age=$age");

my($json) = JSON::from_json($out);

# compute timestr

my($timestr) = strftime("@ %Y%m%d.%H%M%S", localtime($json->{current}->{dt}));

my($weather) = sprintf("%s (%d%)/%0.1fF/%0.1fF/%d% (%0.1fF)", 
 $json->{current}->{weather}[0]->{description},
  $json->{current}->{clouds},
 $json->{current}->{temp},
 $json->{current}->{feels_like},
 $json->{current}->{humidity},
 $json->{current}->{dew_point}
);

my($baro)=sprintf("%0.2fin", $json->{current}->{pressure}/33.863886666667);

my($wind) = windinfo();

# print("$timestr\n$weather\n$wind ($baro)\n");

debug(get_forecasts());

sub windinfo {
  my($dir, $speed, $gust, $unit) = 
    ($json->{current}->{wind_deg}, $json->{current}->{wind_speed},
     $json->{current}->{wind_gust}, "mph");

  if ($speed == 0 && $gust == 0) {return "CALM";}

  my(@winddirs) = ("N","NNE","NE","ENE", "E","ESE","SE","SSE", "S","SSW","SW","WSW", "W","WNW","NW","NNW","N");

  # tweak for unit
  my($mult);
  if ($unit eq "m/s") {
    $mult = 3600/1609.344;
  } elsif ($unit eq "mph") {
    $mult = 1;
  }

  # convert from m/s to mph
  $speed = sprintf("%0.0f", $speed*$mult);
  $gust = sprintf("%0.0f", $gust*$mult);
  $dir = $winddirs[round($dir/22.5)];
  my($ret) = "$dir $speed";
  if ($gust > $speed) {$ret .= "G$gust";}
  return $ret;
}

sub get_forecasts {

  my(@ret)
;
  for $i (0..5) {
    my($dt) = strftime("%a%d", localtime($json->{daily}[$i]->{dt}));
    my($hi) = sprintf("%01.f", $json->{daily}[$i]->{temp}->{max});
    my($lo) = sprintf("%01.f", $json->{daily}[$i]->{temp}->{min});
    my($we) = fix_weather($json->{daily}[$i]->{weather}[0]->{description});
    my($pop) = $json->{daily}[$i]->{pop}*100;
    my($str) = "$dt:$we/$hi/$lo/$pop%";
    push(@ret, $str);
  }

  return join("\n", @ret);
}

sub fix_weather {

  my($weather) = @_;

  my(%hash) = (
	       "clear sky" => "CLR", "overcast clouds" => "OVC",
	       "light" => "LT", "snow" => "SN"
	       );

  for $i (keys %hash) {
    $weather=~s/\s*$i\s*/$hash{$i}/g;
  }

  return $weather;
}

# TODO: parse hourly data

# TODO: personal weather station(s) [direct from HTML?] [existing prog?]

# TODO: add some comments
