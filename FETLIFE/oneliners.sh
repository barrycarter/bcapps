# cleans up fetlife CSV for upload to modeanalytics.com which limits
# filesizes to 500M

# perl -F, -ane 'chomp($F[-1]); sub BEGIN {print "id";} $F[9]=$F[12]; for $i (10..12){$F[$i]="x";} $F[8]=~s%https://flpics\d+.a.ssl.fastly.net/%%; $F[0]=~s/^0+//; $F[8]=~s%https://flassets.a.ssl.fastly.net/images/avatar_missing_60x60.gif%%; print join(",",@F[0..9]),"\n"' ~/FETLIFE/FETLIFE-BY-REGION/20150511/fetlife-user-list-20150511.csv

# perl -F, -ane 'chomp($F[-1]); $F[-2]=$F[-1]; sub BEGIN {print "id";} $F[8]=~s%https://flpics\d+.a.ssl.fastly.net/%%; $F[0]=~s/^0+//; $F[8]=~s%https://flassets.a.ssl.fastly.net/images/avatar_missing_60x60.gif%%; print join(",",@F[0..$#F-1]),"\n"' ~/FETLIFE/FETLIFE-BY-REGION/20150511/fetlife-user-list-20150511.csv

# ignore data that comes from user profiles (it's badly formatted)

fgrep -v 'https://fetlife.com/users/' ~/FETLIFE/FETLIFE-BY-REGION/20150511/fetlife-user-list-20150511.csv | perl -F, -ane 'chomp($F[-1]); $F[-2]=$F[-1]; sub BEGIN {print "id";} $F[8]=~s%https://flpics\d+.a.ssl.fastly.net/%%; $F[0]=~s/^0+//; $F[8]=~s%https://flassets.a.ssl.fastly.net/images/avatar_missing_60x60.gif%%; print join(",",@F[0..$#F-1]),"\n"'

