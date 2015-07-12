# from the list of country files provided by bc-dl-by-region.pl,
# enumerate administrative areas (with country given as number which
# is uglyish)

grep /administrative_areas/ countries-* 


exit;

# same as below, but adds dotted notation to existing CSV for join

# result must be sorted by join field, (ie, "sort -t, -k14,14")

perl -F, -anle 'chomp;$x=lc(join(".",@F[5..7])); $x=~s/[^a-z]/./g; print "$_,$x"'

# perl -F, -anle 'chomp;$x=lc(join(".",@F[5..7])); $x=~s/[^a-z]/./g; print "$_,$x"' ~/FETLIFE/FETLIFE-BY-REGION/fetlife-users-20150519.txt

exit; 

# lowest query below runs too slowly in sqlite3, so trying different ways to
# get same info (devnull is since I'm only timing, don't care about results)

echo "SELECT * FROM (SELECT * FROM (SELECT * FROM kinksters WHERE gender='F' AND age>=18 AND age<=29 AND country='United States') WHERE state='Nebraska') WHERE city='Lincoln' LIMIT 200;" | sqlite3 /sites/DB/fetlife.db > /tmp/output.txt

# this is slow:

# echo "SELECT * FROM kinksters WHERE gender='F' AND age>=18 AND age<=29 AND country='United States' AND state='Nebraska' LIMIT 200;" | sqlite3 /sites/DB/fetlife.db > /tmp/output.txt

# echo "SELECT * FROM kinksters WHERE age BETWEEN 18 AND 29 AND country IN ('United States') AND state IN ('Nebraska') AND city IN ('Lincoln') AND role IN ('sub') AND gender IN ('F') ORDER BY popnum LIMIT 200;" | sqlite3 /sites/DB/fetlife.db 

exit;

# hideous join condition and sort to get final result

join -t, -1 14 -2 1 -o 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 1.10 1.11 1.12 1.13 2.2 2.3 fetlife-users-20150519-no-unicode-city.state.country.csv.srt fetlife-cities-lat-lon-final.txt | sort -k1,1 > fetlife-users-20150519-with-lat-lon.csv

exit;

perl -F, -anle '$x=lc(join(".",@F[5..7])); $x=~s/\s/./g; $x=~s/\.\././g; $x=~s/^\.//; print "$_,$x"' ~/FETLIFE/FETLIFE-BY-REGION/fetlife-users-20150519.txt

exit;

# converts FetLife cities (in CSV) to dotted notation to feed to
# bc-cityfind.pl for later join

perl -F, -anle '$x=lc(join(".",@F[5..7])); $x=~s/\s/./g; $x=~s/\.\././g; $x=~s/^\.//; print $x' ~/FETLIFE/FETLIFE-BY-REGION/fetlife-users-20150519.txt

exit;

# cleans up fetlife CSV for upload to modeanalytics.com which limits
# filesizes to 500M

# perl -F, -ane 'chomp($F[-1]); sub BEGIN {print "id";} $F[9]=$F[12]; for $i (10..12){$F[$i]="x";} $F[8]=~s%https://flpics\d+.a.ssl.fastly.net/%%; $F[0]=~s/^0+//; $F[8]=~s%https://flassets.a.ssl.fastly.net/images/avatar_missing_60x60.gif%%; print join(",",@F[0..9]),"\n"' ~/FETLIFE/FETLIFE-BY-REGION/20150511/fetlife-user-list-20150511.csv

# perl -F, -ane 'chomp($F[-1]); $F[-2]=$F[-1]; sub BEGIN {print "id";} $F[8]=~s%https://flpics\d+.a.ssl.fastly.net/%%; $F[0]=~s/^0+//; $F[8]=~s%https://flassets.a.ssl.fastly.net/images/avatar_missing_60x60.gif%%; print join(",",@F[0..$#F-1]),"\n"' ~/FETLIFE/FETLIFE-BY-REGION/20150511/fetlife-user-list-20150511.csv

# ignore data that comes from user profiles (it's badly formatted)

fgrep -v 'https://fetlife.com/users/' ~/FETLIFE/FETLIFE-BY-REGION/20150511/fetlife-user-list-20150511.csv | perl -F, -ane 'chomp($F[-1]); $F[-2]=$F[-1]; sub BEGIN {print "id";} $F[8]=~s%https://flpics\d+.a.ssl.fastly.net/%%; $F[0]=~s/^0+//; $F[8]=~s%https://flassets.a.ssl.fastly.net/images/avatar_missing_60x60.gif%%; print join(",",@F[0..$#F-1]),"\n"'

