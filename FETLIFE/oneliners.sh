# same as below, but adds dotted notation to existing CSV for join

# result must be sorted by join field, (ie, "sort -t, -k14,14")

perl -F, -anle 'chomp;$x=lc(join(".",@F[5..7])); $x=~s/[^a-z]/./g; print "$_,$x"' ~/FETLIFE/FETLIFE-BY-REGION/fetlife-users-20150519.txt

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

