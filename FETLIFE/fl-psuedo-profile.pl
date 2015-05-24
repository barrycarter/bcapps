#!/bin/perl

# Given a user number, create a psuedo profile page for that user,
# schema.org compliant

# TODO: this will eventually merge with the 404.pl for
# bot.fetlife.94y.info to create fake user pages instead of
# redirecting to fetlife.com

require "/usr/local/lib/bclib.pl";

# TODO: make sure user is numerical
my($user) = @ARGV;

# TODO: handle case where user not in eb
my(@res) = sqlite3hashlist("SELECT * FROM kinksters WHERE id=$user", "/sites/DB/fetlife.db");

my(%hash) = %{$res[0]};

# TODO: add content-type: text/html if needed if called as CGI

$hash{image}=~s/_60.jpg/_200.jpg/;

print << "MARK";

<table itemscope itemtype="http://schema.org/Person" border=1>



</table>

MARK
;

