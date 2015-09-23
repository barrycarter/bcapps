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
my(@res) = mysqlhashlist("SELECT * FROM kinksters WHERE id=$user", "shared");

debug("RES",@res);

my(%hash) = %{$res[1]};

debug("HASH",%hash);

# TODO: add content-type: text/html if needed if called as CGI

$hash{thumbnail}=~s/_60.jpg/_200.jpg/;

# estimate birth year as when visited - (age + .5 years)

my($birth)=strftime("%Y",gmtime($hash{mtime}-($hash{age}+.5)*365.2425*86400));

my($crawl)=strftime("%Y-%m-%d %H:%M:%S UTC", gmtime($hash{mtime}));

my($location) = "$hash{city}, $hash{state}, $hash{country}";

$location=~s/, ,/,/g;

# to improve google search results:

if ($hash{role} eq "sub") {$hash{role} = "sub (submissive)"};
if ($hash{role} eq "Dom") {$hash{role} = "Dom (Dominant)"};

print << "MARK";
<html>
<head>
<title>Fetlife Kinkster $hash{screenname} $hash{age} $gender{$hash{gender}} $hash{role} $location</title>
<meta name=viewport content="width=device-width, initial-scale=1">
</head>
<body>
<center><h3>Fetlife Kinkster $hash{screenname} $hash{age} $gender{$hash{gender}} $hash{role} $location</h3></center>

<table itemscope itemtype="http://schema.org/Person" border=1 width=100%>

<tr>
 <th><img src="$hash{thumbnail}" itemprop="image"></th>
 <th itemprop="name"><a href="https://fetlife.com/users/$hash{id}" itemprop="url">$hash{screenname}</a></th>
</tr>

<tr><th>Age</th><td>
<time itemprop="birthDate" datetime="$birth">$hash{age}</time>
</td></tr>

<tr><th>Gender</th><td itemprop="gender">$gender{$hash{gender}}</td>

<tr><th>Role</th><td itemprop="jobTitle">$hash{role}</td>

<tr><th>Location</th><td itemprop="homeLocation">$location</td>

<tr><th>Last Crawled</th><td>$crawl</td>

</table><p>

Not what you're looking for? Try the <a href="http://search.fetlife.94y.info/" target="_blank">Experimental Unofficial FetLife Search Engine</a>

<p>
<font color='#ff0000' size=+1>

DISCLAIMER: This person is not necessarily who you think they are.<p>

Please remember that anyone can create a FetLife account, and that
FetLife does not validate anyone's information (you can even use a
fake email address).<p>

Some people have created accounts for the "friends" (or enemies) as a
joke or out of malice.<p>

Additionally, one person may use a screenname on FetLife that another
person uses (totally by coincidence) on another site. Someone on
FaceBook, for example, may choose a username without first checking if
someone on FetLife (or some other site) is using it, and vice versa.<p>

Summary: If you see this screenname on another site (or came here by
searching for a screenname), please remember that this may be an
entirely different person, or even a prank listing.<p>

</font>
</body>
</html>
MARK
;

=item mysqlhashlist($query,$db,$user)

Run $query (should be a SELECT statement) on $db as $user, and return
list of hashes, one for each row

NOTE: return array first index is 1, not 0

TODO: add error checking

=cut

sub mysqlhashlist {
  my($query,$db,$user) = @_;
  unless ($user) {$user="''";}
  my(@res,$row);
  chdir(tmpdir());

  write_file($query,"query");

  my($temp) = `date +%N`;
  chomp($temp);
  # TODO: for large resultsets, loading entire output may be bad
  my($out,$err,$res) = cache_command2("mysql -w -u $user -E $db < query","salt=$query&cachefile=/tmp/cache.$temp");

  debug("OUT: $out");

  # go through results
  for $i (split(/\n/,$out)) {
    # new row
    if ($i=~/^\*+\s*(\d+)\. row\s*\*+$/) {$row = $1; $res[$row]={}; next;}
    unless ($i=~/^\s*(.*?):\s*(.*)/) {warn("IGNORING: $_"); next;}
    $res[$row]->{$1}=$2;
  }
  return @res;
}

