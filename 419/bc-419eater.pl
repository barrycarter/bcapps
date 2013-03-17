#!/bin/perl

# 419eater.com has been posting libelous material about me on their
# forums (forums.419eater.com). While I do have legal recourse, it's
# far easier (albeit less effective) to simply post replies to their
# libel. 419eater.com has now taken to rapidly deleting my accounts to
# prevent me from responding to their libel. This script almost
# auto-creates (captcha is still manual) an iMacros file that creates
# a 419eater.com account

require "/usr/local/lib/bclib.pl";

# the domain and base URL to check
my($domain, $baseurl) = ("mobi.web.id", "http://onewaymail.com/en/mob");

use Data::Faker;
my($faker) = Data::Faker->new();

my($name) = lc(join(".",$faker->first_name(),$faker->last_name()));

$str = << "MARK";
' must remove existing cookies manually
PROMPT "remove 419eater.com cookies"
URL GOTO=http://forum.419eater.com/forum/profile.php?mode=register&agreed=true
TAG POS=1 TYPE=INPUT:TEXT ATTR=NAME:username CONTENT=$name
TAG POS=1 TYPE=INPUT:TEXT ATTR=NAME:email CONTENT=$name\@$domain
TAG POS=1 TYPE=INPUT:PASSWORD ATTR=NAME:new_password CONTENT=123
TAG POS=1 TYPE=INPUT:PASSWORD ATTR=NAME:password_confirm CONTENT=123
PROMPT "captcha!"
PAUSE
TAG POS=1 TYPE=INPUT:TEXT ATTR=NAME:answer CONTENT=cold
TAG POS=1 TYPE=INPUT:SUBMIT ATTR=NAME:submit&&VALUE:Submit
URL GOTO=$baseurl/$name
MARK
;

write_file($str,"/home/barrycarter/iMacros/Macros/419eater.iim");

# run the macro
system("/root/build/firefox/firefox -remote 'openURL(http://run.imacros.net/?m=419eater.iim)'");


