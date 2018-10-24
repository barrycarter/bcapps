#!/usr/bin/perl

require "/usr/local/lib/bclib.pl";
require "/home/user/bc-private.pl";

# rewrite of get_forecast to use aeris since api.weather.gov sucks

debug("<result>",get_forecasts(),"</result>");

sub get_forecasts {

  my(%order, %data, @forecasts);

  # intentionally setting age to 3600 long-term to avoid excessive API usage
  my($out, $err, $res) = cache_command2("curl 'https://api.aerisapi.com/forecasts/$private{latitude},$private{longitude}?&filter=daynight&limit=16&client_id=$private{aeris}{accessid}&client_secret=$private{aeris}{secretkey}'", "age=3600");

  my($json) = JSON::from_json($out);

  debug(var_dump("json", $json));

  for $i (@{$json->{response}->[0]->{periods}}) {

    # date and time
#    $i->{startTime}=~m/(\d{4}-\d{2}-\d{2})T(\d{2})/;
    $i->{dateTimeISO}=~m/(\d{4}-\d{2}-\d{2})T(\d{2})/;
    my($date, $time) = ($1, $2);
    # TODO: insanely ugly, convert m-d-y to unix time and then to localtime?!
    my($day) = strftime("%a%d", localtime(str2time($date)));
    # better way to check day/night
#    my($tod) = ($i->{isDaytime} eq "true")?"day":"night";
    debug("ISDAY: $i->{isDay}");
    my($tod) = $i->{isDay}?"day":"night";

    debug("$date/$day/$tod");

    # printing order for this date
    unless ($order{$day}) {$order{$day} = ++$count;}
    # only 7 days
    if ($count >= 8) {last;}

    # forecasted weather
    $data{$day}{$tod}{weather} = parse_forecast($i->{weather});

    # temperature
    if ($tod eq "day") {
      $data{$day}{$tod}{temp} = $i->{maxTempF};
    } else {
      $data{$day}{$tod}{temp} = $i->{minTempF};
    }

    $data{$day}{$tod}{prec} = $i->{pop}."%";

    # TODO: could maybe parse icon for this
#    if ($i->{detailedForecast}=~m/precipitation is (\d+%)/) {
#      $data{$day}{$tod}{prec} = $1;
#    } else {
#      $data{$day}{$tod}{prec} = "0%";
#    }
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
  return $forecasts;
}


sub parse_forecast {
  my($forecast) = @_;

  # handle special case "x then y"
  # TODO: can there be 3 or more here?
  if ($forecast=~m%(.*?)\s+then\s+(.*?)$%) {
    return parse_forecast($1)."->".parse_forecast($2);
  }

  # conversion hash
  # TODO: Chance and Slight Change conflict, do I just hope on order (ugh?)
#  my(%hash) = (
#	       "Rain" => "RA", "And" => "+", "Showers" => "SH",
#	       "Thunderstorms" => "TS", "Cloudy" => "CLD",
#	       "Partly" => "P", "Mostly" => "M",
#	       "Clear" => "CLR", "Sunny" => "CLR",
#	       "Slight Chance" => "??", "Scattered" => "SCT",
#	       "Isolated" => "ISO", "Likely" => "!", "Snow" => "SN",
#	       "Chance" => "?", "Light" => "LT", "T-storms" => "TS",
#	       "with" => "+", "Widespread" => "SCT", "Storms" => "STRMS"
#	       );

  my(%hash) = (
	       "Cloudy" => "CLD", "Mostly" => "M", "with" => "+",
	       "Widespread" => "WSPR", "Rain" => "RA", "Showers" => "SH",
	       "Scattered" => "SCT", "Sunny" => "CLR", "Clear" => "CLR",
	       "Partly" => "P", "Isolated" => "ISO", "Storms" => "STRMS"
	       );

#  debug("HASH", keys %hash);

  for $i (keys %hash) {
#    debug("OLD: $forecast, KEY: $i");
    $forecast=~s/\s*$i\s*/$hash{$i}/g;
#    debug("NEW: $forecast, KEY WAS: $i");
  }

  # can't get this working as a key sigh

#  $forecast=~s/Slight\?/??/g;

  return $forecast;
}


die "TESTING";

# tests by recreating
chdir("/home/barrycarter/BCGIT/WEATHER");
system("rm /tmp/test.db; sqlite3 /tmp/test.db < weather2.sql; ./bc-get-metar.pl | sqlite3 /tmp/test.db; ./bc-get-ship.pl | sqlite3 /tmp/test.db; ./bc-get-buoy.pl | sqlite3 /tmp/test.db");

die "TESTING";
