#!/bin/perl

# Gets local weather from wunderground API solely to print on X root window
# runs from cron every 1m

# -test: in testing mode, use cached data more

# in theory, could get KABQ data from aeris too, more consistent (but
# more delayed?)

# complete rewrite 3 Oct 2018

require "/usr/local/lib/bclib.pl";
require "$bclib{home}/bc-private.pl";

# cache for a long time if testing
if ($globopts{test}) {$age=3600;} else {$age=-1;}

my($out, $err, $res, $json, %output);

# get current data for KABQ

($out, $err, $res) = cache_command2("curl https://api.weather.gov/stations/KABQ/observations/latest", "age=$age");

$json = JSON::from_json($out);
$data = $json->{properties};

$output{timestamp} = strftime("@ %Y%m%d.%H%M%S", localtime(str2time($data->{timestamp})));

# convert to proper temperature units

for $i ("temperature", "windChill", "dewpoint") {

  # special case if undefined
  if (defined($data->{$i}->{value})) { 
    $output{$i} = sprintf("%0.1fF", $data->{$i}->{value}*1.8+32);
  } else {
    $output{$i} = "NAF";
  }
}

# $output{humidity} = sprintf("%0.1f%%", $data->{relativeHumidity}->{value});
$output{humidity} = sprintf("%0.0f%%", $data->{relativeHumidity}->{value});
$output{pressure} = sprintf("%0.2fin", $data->{barometricPressure}->{value}*0.00029530);

# windspeed and gust are in m/s, direction is in degrees

$output{wind} = windinfo($data->{'windDirection'}->{'value'},
			 $data->{'windSpeed'}->{'value'},
			 $data->{'windGust'}->{'value'}, "m/s"
			 );

# TODO: parse this better

$output{weather} = parse_forecast($data->{textDescription});

$str = << "MARK";
$output{timestamp}
$output{weather}/$output{temperature}/$output{windChill}/$output{humidity} ($output{dewpoint})
$output{wind} ($output{pressure})
MARK
;

# now to get forecast data

# 102,118 is the grid where I live (in Albuquerque)

($out, $err, $res) = cache_command2("curl https://api.weather.gov/gridpoints/ABQ/102,118/forecast", "age=$age");

$json = JSON::from_json($out);

for $i (@{$json->{properties}->{periods}}) {

  # date and time
  $i->{startTime}=~m/(\d{4}-\d{2}-\d{2})T(\d{2})/;
  my($date, $time) = ($1, $2);
  # TODO: insanely ugly, convert m-d-y to unix time and then to localtime?!
  my($day) = strftime("%a%d", localtime(str2time($date)));
  my($tod) = $time>=12?"night":"day";

  # printing order for this date
  unless ($order{$day}) {$order{$day} = ++$count;}
  # only 7 days
  if ($count >= 8) {last;}

  # forecasted weather
  $data{$day}{$tod}{weather} = parse_forecast($i->{shortForecast});

  # temperature
  $data{$day}{$tod}{temp} = $i->{temperature};

  # TODO: could maybe parse icon for this
  if ($i->{detailedForecast}=~m/precipitation is (\d+%)/) {
    $data{$day}{$tod}{prec} = $1;
  } else {
    $data{$day}{$tod}{prec} = "0%";
  }
}

for $i (sort {$order{$a} <=> $order{$b}} keys %data) {
  my($str) = join("/", 
		  $data{$i}{day}{weather}, $data{$i}{night}{weather},
		  $data{$i}{day}{temp}, $data{$i}{night}{temp},
		  $data{$i}{day}{prec}, $data{$i}{night}{prec});

  # cleanup string, mostly for "tonight"
  $str=~s%^/+%%;
  $str=~s%/+%/%g;
  push(@forecasts, "$i:$str");
}

my($forecasts) = join("\n", @forecasts);

my($pws) = get_pws_data();

# TODO: temporary + probably a bad idea

($out, $err, $res) = cache_command2("$bclib{githome}/bc-quikbak.pl $bclib{home}/ERR/forecast.inf");

debug("OUT: $out, ERR: $err, RES: $res");

write_file_new("$str$forecasts\n$pws", "$bclib{home}/ERR/forecast.inf");

# TODO: consider stopping if not enough good/recent data
# TODO: add heat index?

# this subroutine is specific to this program, do not confuse w/
# wind() in bclib.pl

sub windinfo {
  my($dir, $speed, $gust, $unit) = @_;

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

# parses shortForecast

sub parse_forecast {
  my($forecast) = @_;

  # handle special case "x then y"
  # TODO: can there be 3 or more here?
  if ($forecast=~m%(.*?)\s+then\s+(.*?)$%) {
    return parse_forecast($1)."+".parse_forecast($2);
  }

  # TODO: work in progress as I see more forecasts
  # NOTE: order is important (eg, "Slight Chance" before "Chance")

  $forecast=~s/Mostly\s+/M/;

  # these mean the same thing (wow!)
  $forecast=~s/Partly (Cloudy|Sunny)/PCLD/;

  $forecast=~s/(Sunny|Clear)/CLR/;

  $forecast=~s/Slight Chance\s+/??$1/;

  $forecast=~s/Rain Showers/RA/;

  $forecast=~s/Showers And Thunderstorms/TS/;

  $forecast=~s/Chance\s+/?$1/;

  $forecast=~s/Cloudy/CLD/;

  # TODO: not really happy about this one (so not generalizing)
  $forecast=~s/Scattered TS/TS/;

  return $forecast;
}

# NOTE: this is a subroutine purely for code cleanliness, and is
# specific to this program

sub get_pws_data {

  my(%output);

  # $age is global

  my($out, $err, $res) = cache_command2("curl 'https://api.aerisapi.com/observations/PWS_LORAXABQ?&client_id=$private{aeris}{accessid}&client_secret=$private{aeris}{secretkey}'", "age=$age");

  my($json) = JSON::from_json($out);

  my($data) = $json->{response}->{ob};

  $output{timestamp} = strftime("%Y%m%d.%H%M%S", localtime($data->{timestamp}));

  # convert to proper temperature units
  for $i ("tempC", "windchillC", "dewpointC") {

  # special case if undefined
    if (defined($data->{$i})) {
      $output{$i} = sprintf("%0.1fF", $data->{$i}*1.8+32);
    } else {
      $output{$i} = "NAF";
    }
  }

  # ugly special case since station reports pointless windchill
  if (abs($output{windchillC}-$output{tempC}) < 1) {
    $output{windchillC} = "NAF";
  }

  $output{humidity} = sprintf("%0.0f%%", $data->{humidity});
  $output{pressure} = sprintf("%0.2fin", $data->{pressureIN});

  # windspeed and gust are in m/s, direction is in degrees

  $output{wind} = windinfo($data->{'windDirDEG'}, $data{'windSpeedMPH'},
			 $data->{'windGustSpeedMPH'}, "mph");

  # TODO: last line is just for fun and temporary
  my($str) = << "MARK";
Local/$output{tempC}/$output{windchillC}/$output{humidity} ($output{dewpointC}) [$output{timestamp}]
$output{wind} ($output{pressure})
Light: $data->{light}, Sky: $data->{sky}, Rad: $data->{solradWM2}
MARK
;

  return $str;

}
