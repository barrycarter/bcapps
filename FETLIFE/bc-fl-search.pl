#!/bin/perl

# Frontend to shared.db.mysql.94y.info that allows access to some
# simple queries

require "/usr/local/lib/bclib.pl";

my($link);
print "Content-type: text/html\n\n";

# for now
$globopts{debug}=1;

# if there is a query, handle it

# defaults are read first and are trumped by QUERY_STRING
my($defaults) = ("gender=F&lowage=18&highage=29&country=United+States&role=sub&city=Lincoln&state=Nebraska");

my(%chunks)=str2hash("$defaults&$ENV{QUERY_STRING}");

# treat lowage and highage special (both must be set)
my(@conds) = ("age BETWEEN $chunks{lowage} AND $chunks{highage}");

for $i (keys %chunks) {

  # ignore low/highage (but keep them for later form)
  if ($i=~/^(high|low)age$/) {next;}
  # and submit button
  if ($i eq "submit") {next;}

  # empty values and "*" are ignored
  if ($chunks{$i}=~/^\s*$/ || $chunks{$i} eq "*") {next;}

  # space correction
  $chunks{$i}=~s/\+/ /g;

  # left match (city/state only)
  if ($i eq "city" || $i eq "state") {
    push(@conds, "$i LIKE '$chunks{$i}%'");
    next;
  }

  # conditions (the use of IN instead of = does nothing for now, but may later)
  push(@conds, "$i IN ('$chunks{$i}')");
}

# do the below only if there's an actual query

if ($chunks{"submit"}) {

  my($conds)=join(" AND ",@conds);
  # TODO: allow user to set limit
  my($query) = "SELECT * FROM thumbs WHERE $conds ORDER BY popnum LIMIT 200";

  # run curl with data in tmp dir
  my($tempdir) = tmpdir();
  write_file($query, "$tempdir/query");
  my($out,$err,$res) = cache_command2("curl -D - -d \@$tempdir/query http://post.shared.db.mysql.a.94y.info/","salt=$tmpdir");
  # TODO: handle fail case here
  $out=~/^Location: (.*?)$/m;
  my($url) = $1;
  $link = "<font size=+2>&gt;&gt;&gt; <a href='$url' target='_blank'>Click here to see your results</a> (opens in new window)</font>";
}

unless ($link) {$link="<font size=-1>(a link to your search results will appear here)</font>";}

my($options) = read_file("fl-forms.txt");

# default values to whatever user entered

$options=~s%<genders>(.*?)</genders>%%s;
my(@genders) = split(/\n/, $1);
unshift(@genders, "*:Any Gender");
$genders = html_select_list("gender",\@genders,$chunks{gender});

$options=~s%<roles>(.*?)</roles>%%s;
# case-insensitive sort
my(@roles) = split(/\n/, $1);
@roles = sort {lc($a) cmp lc($b)} @roles;
unshift(@roles, "*:Any Role");
$roles = html_select_list("role",\@roles,$chunks{role});

$options=~s%<countries>(.*?)</countries>%%s;
my(@cunts) = split(/\n/, $1);
unshift(@cunts, "*:Any Country");
$cunts = html_select_list("country",\@cunts,$chunks{country});

my(@ages) = (18..99);
my(@rages) = reverse(@ages);
$lowage = html_select_list("lowage",\@ages,$chunks{lowage});
$highage = html_select_list("highage",\@rages,$chunks{highage});

my($form) = << "MARK";

$link<p>

Need help? Form not working? Read the <a href="#notes">notes</a>, or
email openfetlife\@mail.com

<form action="/bc-fl-search.pl" method="GET"><table border>

<tr><th colspan=2>
EXPERIMENTAL UNOFFICIAL FetLife Search Engine Form (not affiliated with FetLife)
</th></tr>

<tr><th>Gender</th><td>$genders
<br><em><font size=-1><a href="http://724da4c231198317b884338cd2f0c0ec.shared.db.mysql.94y.info/" target="_blank">(breakdown by gender)</font></em>
</td></tr>

<tr><th>Age</th><td>$lowage to $highage
<br><em><font size=-1><a href="http://0c06b634327ae188e0d4454041012ea6.shared.db.mysql.94y.info/" target="_blank">(breakdown by age)</a>; some kinksters list their birthyear as 1920 for privacy, so 94 or 95 effectively means "no age provided")</font></em>
</td></tr>



<tr><th>Role</th><td>$roles
<br><em><font size=-1><a href="http://73b2535d8c94c331767afc6129fdf0cb.shared.db.mysql.94y.info/" target="_blank">(breakdown by roles)</a>; FetLife recently introduced several new roles, most of which are virtually unused</font></em>
</td></tr>

<tr><th>City</th><td><input type='text' name='city' value='$chunks{city}'>
<br><em><font size=-1>(first few letters OK, but no abbreviations: ok to use "Saint L" for Saint Louis, but not "St. L"; leave blank for all cities)</font></em>
</td></tr>

<tr><th>State</th><td><input type='text' name='state' value='$chunks{state}'>
<br><em><font size=-1>(first few letters OK, but no abbreviations: ok to use "Mississ" for Mississippi, but not "MS"; leave blank for all states)</font></em>
</td></tr>

<tr><th>Country</th><td>$cunts
<br><em><font size=-1>
<a href="http://a66e284742512cee1441fbbcf808eed6.shared.db.mysql.94y.info/" target="_blank">(breakdown by country)</a>; many kinksters use "Antarctica" to mean "I do not wish to reveal my location"
</font></em>
</td></tr>

<tr><th colspan=2><input name="submit" type="submit" value="SEARCH"></th></tr>

</table></form>

MARK
;

print $form;

print read_file("searchform.html");

=item html_select_list($name, \@list, $selected="")

Create an HTML form SELECT list from \@list with name $name.

If $selected is set, key matching $selected will be pre-SELECTed

Ignores empty list items.

If list is "str1:str2", the value is str1, but str2 is printed.

TODO: need to allow generic separator character (or true hashes)

=cut

sub html_select_list {
  my($name,$listref,$selected) = @_;
  my(@ret)=("<select name='$name'>");
  for $i (@$listref) {
    if ($i=~/^\s*$/) {next;}

    # split into key/value
    my($k,$v);
    if ($i=~/^(.*?):(.*)$/) {($k,$v)=($1,$2);} else {$k=$v=$i;}

    # SELECTed?
    if ($k eq $selected) {
      push(@ret,"<option value='$k' SELECTED>$v</option>");
    } else {
      push(@ret,"<option value='$k'>$v</option>");
    }
  }
  push(@ret,"</select>");
  return join("\n",@ret)."\n";
}
