#!/bin/perl

# gets PWS data for specific station from Aeris weather API; replaced
# actually calling local weather directly from bc-bg3.pl which is a
# bad idea

require "/usr/local/lib/bclib.pl";
require "$bclib{home}/bc-private.pl";

# TODO: age=120 is holdover from doing this in bc-bg3.pl, consider removing

my($out, $err, $res) = cache_command2("curl 'https://api.aerisapi.com/observations/PWS_LORAXABQ?&client_id=$private{aeris}{accessid}&client_secret=$private{aeris}{secretkey}'", "age=120");

my($json) = JSON::from_json($out);

debug(var_dump("json", $json));


=item comment

json->{'response'}->{'ob'}->{'dateTimeISO'} = '2018-10-04T11:20:00-06:00';
json->{'response'}->{'ob'}->{'dewpointF'} = 51;
json->{'response'}->{'ob'}->{'humidity'} = 38;
json->{'response'}->{'ob'}->{'icon'} = 'pcloudy.png';
json->{'response'}->{'ob'}->{'tempF'} = 79;
json->{'response'}->{'ob'}->{'weather'} = 'Mostly Sunny';
json->{'response'}->{'ob'}->{'windDir'} = 'SSW';
json->{'response'}->{'ob'}->{'windGustMPH'} = 6;
json->{'response'}->{'ob'}->{'windMPH'} = 0;
json->{'response'}->{'ob'}->{'windSpeedMPH'} = 0; # which one to use?
json->{'response'}->{'obDateTime'} = '2018-10-04T11:20:00-06:00';

json->{'response'}->{'ob'}->{'light'} = 70; # just curious about this one
json->{'response'}->{'ob'}->{'sky'} = 19;
json->{'response'}->{'ob'}->{'skywxSrc'} = 'KABQ';
json->{'response'}->{'ob'}->{'solradWM2'} = 663;





=cut


