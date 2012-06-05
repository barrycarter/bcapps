#!/bin/perl

# Another program that benefits only me <h>(my goal is to create one
# that benefits no body, and then maybe one that harms people
# including myself)</h>, creates an IIM iMacros file to download my
# allybank.com information

# The macro is mostly fixed, only the dates change

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

# the macro is mostly fixed (I could even read it from current version?)

# the "accountSelect... e*" is some hex representation of my account
# (hardcoding the first nybble is hopefully safe); do a 'view source'
# and change 'e*' if needed)

$macro = << "MARK";
TAB T=1
URL GOTO=http://www.ally.com/
TAG POS=1 TYPE=SPAN ATTR=TXT:log<SP>in
TAG POS=1 TYPE=INPUT:TEXT FORM=NAME:actionForm ATTR=ID:username CONTENT=$ally{username}
TAG POS=1 TYPE=INPUT:BUTTON FORM=ID:noautocomplete ATTR=NAME:button&&VALUE:Continue
SET !ENCRYPTION NO
TAG POS=1 TYPE=INPUT:PASSWORD FORM=NAME:actionForm ATTR=NAME:password CONTENT=$ally{password}
TAG POS=1 TYPE=INPUT:SUBMIT FORM=ID:noautocomplete ATTR=NAME:button&&VALUE:Login
URL GOTO=https://secure.ally.com/allyWebClient/downloadAccountActivity.do
TAG POS=1 TYPE=SELECT ATTR=ID:accountSelect CONTENT=%e*
TAG POS=1 TYPE=INPUT:TEXT FORM=NAME:downloadActivityForm ATTR=ID:date1 CONTENT=:STARTDATE:
TAG POS=1 TYPE=INPUT:TEXT FORM=NAME:downloadActivityForm ATTR=ID:date2 CONTENT=:ENDDATE:
TAG POS=1 TYPE=SELECT ATTR=ID:formatSelect CONTENT=%Money
TAG POS=1 TYPE=INPUT:SUBMIT FORM=NAME:downloadActivityForm ATTR=ID:mainSubmit
SAVEAS TYPE=CPL FOLDER=* FILE=+_{{!NOW:yyyymmdd_hhnnss}}
MARK
;

# now and 17.5 months ago (18 is limit, but playing it safe)
$now = time();
$enddate = strftime("%m/%d/%Y", localtime($now));
$startdate = strftime("%m/%d/%Y", localtime($now-365.2425/12*17.5*86400));

# substiute into macro (TODO: redundant code, use hash?, create generalized subroutine?)
$macro=~s/:STARTDATE:/$startdate/isg;
$macro=~s/:ENDDATE:/$enddate/isg;

write_file($macro, "/home/barrycarter/iMacros/Macros/bc-create-ally.iim");


