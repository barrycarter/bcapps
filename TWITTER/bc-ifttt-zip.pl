#!/bin/perl

# renames an IFTTT JSON file based on user and date of backup

require "/usr/local/lib/bclib.pl";

my($data, $fname) = cmdfile();

# remove old style carriage returns

$data=~s/[\r\n]//sg;

my($json) = JSON::from_json($data);

debug(var_dump("JSON", $json));

# debug("DATA: $data, $json");

# JSON->{'data'}->{'me'}->{'email'}
# JSON->{'data'}->{'me'}->{'login'}

# no indication WHEN backup was created?!

# for freecodecamp:

# JSON->{'email'} is email

# JSON->{'completedChallenges'}->[245]->{'completedDate'} highest
# value MAY be useful

# JSON->{'calendar'} keys MAY be helpful

# for INSTAGRAM: profile.json contains name, latest entry in
# account_history.json may be time of backup (it's actually time of
# last login, but also timestamps in the zip file itself

