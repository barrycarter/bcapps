# shell one liners

# speed up MP3s pointlessly (in a way that can be piped to parallel safely)
find . -iname '*.mp3' | perl -nle 's/\.mp3$//; print "/usr/bin/mplayer -ao \47pcm:fast:file=/tmp/$_.wav\47 \47$_.mp3\47; sox \47/tmp/$_.wav\47 \47/tmp/$_-temp.wav\47 tempo 1.5 norm; lame \47/tmp/$_-temp.wav\47 \47/tmp/$_-fast.mp3\47"'

exit;

# useful cron job to screenshot yourself every minute
* * * * * xwd -root | convert xwd:- /home/barrycarter/XWD/pic.`date +\%Y\%m\%d:\%H\%M\%S`.png

exit;

# to grep for number of '-' in a bz2 file:
bzcat 723650-23050.res.bz2 | fgrep -c -- -

exit;

# bytes 67-70 appear to identify an SD card partition; replace
# /dev/sdd w SD device (I have no idea why I believe this or even if
# its true)

perl -le 'open(A,"/dev/sdd1")||die("Cant open /dev/sdd, $!"); seek(A,67,0); read(A,$val,4); print "VAL: $val\n"; $val=~s/(.)/ord($1)."."/iseg; print $val'

exit;

# find IP addresses for hostnames (even hostnames like
# br.com.desktop.201-77-120-14 have nonobvious IP addresses, perhaps
# due to reassignment; for that host, the IP is 67.215.65.132)

perl -anle 'if ($F[1]=~/^[\d\.]+$/) {next;} $fname=substr($F[1],0,2); print "host -a $F[1] >> $fname-ip.txt"' samplehosts4.txt | sort -R >! /tmp/ips.txt

exit;

# processes sorted by time

ps -www -ax -eo 'pid etime rss vsz args'

exit;

# similar to below for
# http://www.census.gov/geo/www/gazetteer/files/Gaz_places_national.txt;
# this file doesn't have population, so sorting by land area = not
# ideal; trimming off CDP/city/town which is type of place, not part
# of name

perl -F"\t" -anle '$F[3]=~s/\s*(metro government|consolidated government|metropolitan government|\(balance\)|city and borough|borough|city|town|CDP)$//; print "$F[4],$F[3],$F[0]"' Gaz_places_national.txt | sort -nr | cut -d, -f 2-3 | tee /home/barrycarter/BCGIT/GEOLOCATION/big-area-cities.txt

exit;

# using http://download.geonames.org/export/dump/cities1000.zip (US
# cities only, just for geolocation)
perl -F"\t" -anle 'if ($F[8] eq "US") {print "$F[14],$F[2],$F[10]"}' cities1000.txt | sort -nr | cut -d, -f 2-3| tee /home/barrycarter/BCGIT/GEOLOCATION/big-us-cities.txt

exit;

# infinite insane IP testing
perl -e 'for(;;){@ip=();for(1..4){push(@ip,int(rand(256)))}print "mtr -rwc 1  ",join(".",@ip),">>/var/tmp/mtr-single-file-test.txt\n"}'|less


exit;

# the results of GEOLOCATION/bc-random-ips.pl (ignoring my router, my gateway [for privacy], and '???', the meaningless result)

egrep -h '[0-9]+\. ' -R /var/tmp/mtr-single-file-test.txt | perl -anle 'print $F[1]' | sort | uniq | egrep -v '^albq|^netgear\.local\.lan|^\?\?\?' >! /home/barrycarter/BCGIT/GEOLOCATION/samplehosts2.txt

exit;

# stations in weather table but not in stations table
echo "SELECT DISTINCT m.station_id FROM metar m LEFT JOIN stations s ON (m.station_id = s.metar) WHERE s.metar IS NULL ORDER BY m.station_id;" | sqlite3 /sites/DB/metarnew.db

exit;

# mathematica format for sunrise/set data
perl -anle 'sub BEGIN {print "data={"} sub END {print "}"} unless (/^[0-9]/) {next;} print "{"; for $i (0..11) {$x=substr($_,4+11*$i,10);$x=~s/\s/,/;$x=~s/\s*$//; $x=~s/\-{4},\-{4}/0000,0000/; $x=~s/\*{4},\*{4}/2400,0000/; print "{$x},"}; print "},"' /home/barrycarter/BCGIT/db/srss-70n.txt

exit;

# better moonrise/set
echo "SELECT event, SUBSTR(REPLACE(TIME(time), ':',''),1,4) AS stime,(strftime('%s',DATE(time))-strftime('%s', DATE('now')))/86400 AS dist FROM abqastro WHERE event IN ('MR','MS') AND ABS(dist)<=1 ORDER BY time;" | sqlite3 /home/barrycarter/BCGIT/db/abqastro.db

# WHERE DATE(time) IN (DATE('now','localtime'), DATE('now','localtime', '+1 day')) AND event='MS' ORDER BY time LIMIT 1;" 

exit;

# last 60 days
perl -le 'use POSIX; for $i (0..60) {$now=time()-$i*86400; print strftime("%Y%m%d",localtime($now))}'

exit;



