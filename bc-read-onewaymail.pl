#!/bin/perl

# downloads no-registration-required public email address messages
# from onewaymail.com

require "/usr/local/lib/bclib.pl";

# TODO: dont hardcode
$url = "http://onewaymail.com/en/mob/Monroe.Reilly";

# age just for testing, onewayemail.com seems a bit slow
($out,$err,$res) = cache_command("curl $url","age=600");

debug("OUT: $out");


