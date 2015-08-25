#!/bin/perl

# Another program that benefits only me <h>(my goal is to create one
# that benefits no body, and then maybe one that harms people
# including myself)</h>, creates an IIM iMacros file to download my
# Capital One credit card information

# --norun: create the macro, but don't run it in Firefox

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

$macro = << "MARK";
TAB T=1
URL GOTO=https://servicing.capitalone.com/c1/Login.aspx
FRAME F=2
TAG POS=1 TYPE=INPUT:TEXT FORM=NAME:login ATTR=ID:uname CONTENT=$private{capitalone}{username}
TAG POS=1 TYPE=INPUT:PASSWORD FORM=NAME:login ATTR=ID:cofisso_ti_passw CONTENT=$private{capitalone}{password}
TAG POS=1 TYPE=INPUT:IMAGE FORM=NAME:login ATTR=ID:cofisso_btn_login
TAG POS=1 TYPE=A ATTR=ID:transactionsLink0
TAG POS=1 TYPE=A ATTR=ID:view_download_transactions_link_ID
TAG POS=1 TYPE=INPUT:TEXT FORM=NAME:MAINFORM ATTR=ID:txtFromDate_TextBox CONTENT=:STARTDATE:
TAG POS=1 TYPE=INPUT:TEXT FORM=NAME:MAINFORM ATTR=ID:txtToDate_TextBox CONTENT=:ENDDATE:
TAG POS=1 TYPE=INPUT:RADIO FORM=ID:MAINFORM ATTR=ID:ctlStatementFilter_1
ONDOWNLOAD FOLDER=* FILE=+_{{!NOW:yyyymmdd_hhnnss}} WAIT=YES
TAG POS=1 TYPE=INPUT:IMAGE FORM=ID:MAINFORM ATTR=ID:btnDownload
MARK
;

# now and 80 days ago (90 is limit, but playing it safe)
$now = time();
$enddate = strftime("%m/%d/%Y", localtime($now));
$startdate = strftime("%m/%d/%Y", localtime($now-80*86400));

# substiute into macro (TODO: redundant code, use hash?, create generalized subroutine?)
$macro=~s/:STARTDATE:/$startdate/isg;
$macro=~s/:ENDDATE:/$enddate/isg;

write_file($macro, "/home/barrycarter/iMacros/Macros/bc-create-capone.iim");

# if not running macro, stop here
if ($globopts{norun}) {exit 0;}

die "TESTING";

# run the macro
# TODO: yes, this is a terrible place to keep my firefox
($out, $err, $res) = cache_command("/root/build/firefox/firefox -remote 'openURL(http://run.imacros.net/?m=bc-create-ally.iim,new-tab)'");

# not sure how long it takes to run above command, so wait until
# trans*.ofx shows up in download directory (and is fairly recent)

# TODO: this is hideous (-mmin -60 should be calculated not a guess)

for (;;) {
  ($out, $err, $res) = cache_command("find '/home/barrycarter/Download/' -iname 'trans*.ofx' -mmin -60");
  if ($out) {last;}
  debug("OUT: $out");
  sleep(1);
}

# send file to ofx parser
($out, $err, $res) = cache_command("/home/barrycarter/BCGIT/bc-parse-ofx.pl $out");

# useless fact: allybank.com names their OFX dumps as trans[x], where
# x is the unix time to the millisecond (I think)
