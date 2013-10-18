# convert meso_station.cgi.html to TSV for stations db
fgrep 'stn=' meso_station.cgi.html | perl -nle 's/<a href=".*?">//;s/<\/a>/ /;s/\s*ft//; @f=split(/\s{2,}/,$_); print join("\t", ($f[0], "NULL", $f[2]));'

exit;

# obtain 5m-ly data from local weather station

perl -le 'for $y (2009..2012) {for $m (1..12) {for $d (1..31) {print "curl -o local-$y-$m-$d.txt \47http://www.wunderground.com/weatherstation/WXDailyHistory.asp?ID=KNMALBUQ80&graphspan=day&month=$m&day=$d&year=$y&format=1\47"}}}'
