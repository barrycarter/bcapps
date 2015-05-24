#!/bin/perl

# Given a user number, create a psuedo profile page for that user,
# schema.org compliant

# TODO: this will eventually merge with the 404.pl for
# bot.fetlife.94y.info to create fake user pages instead of
# redirecting to fetlife.com

require "/usr/local/lib/bclib.pl";

# gender mapping

%gender = ("M", "Male", "F", "Female", "CD/TV" =>
"Crossdresser/Transvestite", "MtF", "Trans - Male to Female", "FtM" =>
"Trans - Female to Male", "TG", "Transgender", "GF", "Gender Fluid",
"GQ", "Genderqueer", "IS", "Intersex", "B", "Butch", "FEM","Femme","",
"Not Applicable");

# TODO: make sure user is numerical
my($user) = @ARGV;

# TODO: handle case where user not in eb
my(@res) = sqlite3hashlist("SELECT * FROM kinksters WHERE id=$user", "/sites/DB/fetlife.db");

my(%hash) = %{$res[0]};

# TODO: add content-type: text/html if needed if called as CGI

$hash{thumbnail}=~s/_60.jpg/_200.jpg/;

# estimate birth year as when visited - (age + .5 years)

my($birth)=strftime("%Y",gmtime($hash{mtime}-($hash{age}+.5)*365.2425*86400));

my($location) = "$hash{city}, $hash{state}, $hash{country}";

$location=~s/, ,/,/g;

print << "MARK";

<table itemscope itemtype="http://schema.org/Person" border=1 width=100%>

<tr>
 <th><img src="$hash{thumbnail}" itemprop="image"></th>
 <th itemprop="name">$hash{screenname}</th>
</tr>

<tr><th>Age</th><td itemprop="birthDate">$birth</td></tr>

<tr><th>Gender</th><td itemprop="gender">$gender{$hash{gender}}</td>

<tr><th>Role</th><td itemprop="jobTitle">$hash{role}</td>

<tr><th>Location</th><td itemprop="homeLocation">$location</td>

<tr><th>URL</th><td itemprop="url">https://fetlife.com/users/$hash{id}</td></tr>




</table>

MARK
;

