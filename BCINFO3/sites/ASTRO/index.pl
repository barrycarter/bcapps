#!/bin/perl

# Frontend to astro.db.mysql.94y.info that allows access to some
# simple queries to p2 (but not to p3, p4, p5, p6)

require "/usr/local/lib/bclib.pl";

my($link);

# TODO: removing Mercury for p2 below; but this is dumb way to do it
my(@planets) = ("*:Any planet", "Mercury", "Venus", "Mars", "Jupiter",
"Saturn", "Uranus");
my(@planets2) = ("*:Any planet", "Venus", "Mars", "Jupiter",
"Saturn", "Uranus");

print "Content-type: text/html\n\n";

# for now
$globopts{debug}=1;

# if there is a query, handle it

# defaults are read first and are trumped by QUERY_STRING
my($defaults) = ("p1=Mercury&p2=Venus&lowyear=2014&highyear=2016&sep=6&solarsep=18");

my(%chunks)=str2hash("$defaults&$ENV{QUERY_STRING}");

# conditions
my(@conds) = (
 "year BETWEEN $chunks{lowyear} AND $chunks{highyear}",
 "sep < $chunks{sep}", "solarsep > $chunks{solarsep}"
);

# if p1 and/or p2 are not "*"
if ($chunks{p1} ne "*") {push(@conds,"p1='$chunks{p1}'");}
if ($chunks{p2} ne "*") {push(@conds,"p2='$chunks{p2}'");}

# do the below only if there's an actual query

if ($chunks{"submit"}) {

  my($conds)=join(" AND ",@conds);
  my($query) = << "MARK";

SELECT UPPER(p1) AS "Planet 1", UPPER(p2) AS "Planet 2", CONCAT(year,"-",LPAD(month,2,"0"),"-",LPAD(day,2,"0")," ",time) AS "Date/Time", FORMAT(sep,3) AS "Separation<br>(degrees)", FORMAT(solarsep,3) AS "Sun Distance<br>(degrees)", star AS "Nearest Star", FORMAT(starsep,3) AS "Star Distance<br>(degrees)" FROM p2 WHERE $conds ORDER BY year,month,day LIMIT 200;

MARK
;

  # run curl with data in tmp dir
  my($tempdir) = tmpdir();
  write_file($query, "$tempdir/query");
  my($out,$err,$res) = cache_command2("curl -D - -d \@$tempdir/query http://post.astro.db.mysql.94y.info/","salt=$tmpdir");
  # TODO: handle fail case here
  $out=~/^Location: (.*?)$/m;
  my($url) = $1;
  $link = "<font size=+2>&gt;&gt;&gt; <a href='$url' target='_blank'>Click here to see your results</a> (opens in new window)</font>";
}

unless ($link) {$link="<font size=-1>(a link to your search results will appear here)</font>";}

$planets = html_select_list("p1",\@planets,$chunks{p1});
# can't choose mercury for 2nd field, meaningless
$planets2 = html_select_list("p2",\@planets2,$chunks{p2});

my($form) = << "MARK";

$link<p>

Need help? Form not working? Read the <a href="#notes">notes</a>, or
email astro\@barrycarter.info

<form action="/index.pl" method="GET"><table border>

<tr><th colspan=2>Conjunctions database searh form</th></tr>

<tr><th>Planet 1</th><td>$planets
<br><em><font size=-1>

The first conjuncting planet, the one closer to the Sun (use "all
planets" to see all conjunctions)

</font></em>
</td></tr>

<tr><th>Planet 2</th><td>$planets2
<br><em><font size=-1>

The second conjuncting planet, the one farther from the Sun (use "all planets" to see all conjunctions).<br>

Note that Mercury is not on the list, since it can never be the
farther planet.<br>

Note: if you choose "all planets" for Planet 2 but not for Planet 1,
you will get unpredictable results. If you choose "all planets" for
Planet 2, you *must* choose "all planets" for Planet 1.

</font></em>
</td></tr>

<tr><th>Years</th><td>

<input type='text' size='10' name='lowyear' value='$chunks{lowyear}'>
to
<input type='text' size='10' name='highyear' value='$chunks{highyear}'>

<br><em><font size=-1>

The years for which you want to see conjunctions. This database covers
conjunctions from the year -13001 to 16999 (which is smaller than
largest possible range, I am working to correct this).

<br>

I follow the standard astronomical convention that 1BCE is year 0,
2BCE is year -1, and so on, partly so you can use Stellarium to view
these conjunctions:

<a href="http://www.stellarium.org/wiki/index.php/FAQ#.22There_is_no_year_0.22.2C_or_.22BC_dates_are_a_year_out.22">http://www.stellarium.org/wiki/index.php/FAQ</a>

</font></em></td></tr>

<tr><th>Separation</th><td>

<input type='text' size='10' name='sep' value='$chunks{sep}'>

<br><em><font size=-1>

The maximum angular separation between the two conjuncting
planets. This database contains conjunctions up to 6 degrees apart (so
setting this value higher than 6 won't give you more results, but setting it lower than 6 will give you fewer results)

</font></em></td></tr>

<tr><th>Solar Distance</th><td>
<input type='text' size='10' name='solarsep' value='$chunks{solarsep}'>
<br><em><font size=-1>

The minimum distance from the Sun for this conjunction. Conjunctions
close to the Sun are difficult to see, since they occur during
twilight. Use '0' to see all conjunctions, regardless of how close
they are to the Sun.

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
