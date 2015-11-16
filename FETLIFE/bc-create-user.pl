#!/bin/perl

# Writes (and runs?) an iMacro script to create a FetLife user and log
# it in, in order to obtain a session cookie

require "/usr/local/lib/bclib.pl";
require "/home/barrycarter/bc-private.pl";

# TODO: create $nickname, $email, $password

# this creates fields with no repeated letters (which is unnecessary but silly)
my(@list) = ("a".."z");

my(@r) = randomize(\@list);

$nickname = join("",@r[0..6]);
$email = join("",@r[7..12]);
$email_domain = join("",@r[13..19]).".com";

# this is my personal override because I actually *want* to get FL
# emails, at least as a test

$email_domain = $private{secret}{domain};

$email = "$email\@$email_domain";
$password = join("",@r[20..25]);

print << "MARK";
TAB T=1
URL GOTO=https://fetlife.com/signup
TAG POS=1 TYPE=INPUT:TEXT FORM=ACTION:/users ATTR=ID:user_nickname CONTENT=$nickname
TAG POS=1 TYPE=SELECT FORM=ACTION:/users ATTR=ID:user_sex CONTENT=%M
TAG POS=1 TYPE=SELECT FORM=ACTION:/users ATTR=ID:user_sexual_orientation CONTENT=%Straight
TAG POS=1 TYPE=SELECT FORM=ACTION:/users ATTR=ID:user_role CONTENT=%Dominant
TAG POS=1 TYPE=SELECT FORM=ACTION:/users ATTR=ID:user_date_of_birth_1i CONTENT=%1970
TAG POS=1 TYPE=SELECT FORM=ACTION:/users ATTR=ID:user_date_of_birth_3i CONTENT=%18
TAG POS=1 TYPE=SELECT FORM=ACTION:/users ATTR=ID:user_date_of_birth_2i CONTENT=%5
TAG POS=1 TYPE=SELECT FORM=ACTION:/users ATTR=ID:user_country_id CONTENT=%233
TAG POS=1 TYPE=SELECT FORM=ACTION:/users ATTR=ID:user_administrative_area_id CONTENT=%3964
TAG POS=1 TYPE=SELECT FORM=ACTION:/users ATTR=NAME:user[city_id] CONTENT=%8368
TAG POS=1 TYPE=INPUT:TEXT FORM=ACTION:/users ATTR=ID:user_email CONTENT=$email
TAG POS=1 TYPE=INPUT:TEXT FORM=ACTION:/users ATTR=ID:user_email_confirmation CONTENT=$email
TAG POS=1 TYPE=INPUT:PASSWORD FORM=ACTION:/users ATTR=ID:user_password CONTENT=$password
TAG POS=1 TYPE=INPUT:PASSWORD FORM=ACTION:/users ATTR=ID:user_password_confirmation CONTENT=$password
TAG POS=1 TYPE=INPUT:TEXT FORM=ACTION:/users ATTR=ID:user_spam_check_foo CONTENT=7
TAG POS=1 TYPE=INPUT:CHECKBOX FORM=ACTION:/users ATTR=ID:user_terms_and_conditions CONTENT=YES
' prompt and pause for captcha
PROMPT captcha
PAUSE
TAG POS=1 TYPE=INPUT:SUBMIT FORM=ID:new_user ATTR=NAME:commit&&VALUE:Join<SP>FetLife
MARK
;
