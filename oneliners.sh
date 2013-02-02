# shell one liners

# people who ive dealt with but were never pinged (for completeness)
# I add these to toping.txt and then ping them (auto-exclude for repeats)

egrep '^From: ' ~/mail/leonard.zeptowitz | perl -nle 'if (/<(.*?\@.*?)>/) {print $1}' | sort | uniq | grep -v zeptowitz

exit;

# hack to find gmail addresses in scam-baiting mailbox (not 100%)

egrep -i '^from:|^reply-to:|^from ' ~/mail/leonard.zeptowitz | fgrep -i gmail | sort | uniq

# grep gmail /home/barrycarter/mail/leonard.zeptowitz | perl -nle 'while (s/([a-z0-9\.\+]+\@[a-z0-9\.]+\.[a-z]+)//) {print $1}' | fgrep -iv zeptowitz | sort | uniq

exit;

# time in all time zones in zone.tab (but not all files in
# /usr/share/zoneinfo) to find earliest/latest (did Samoa just trump
# Chatam Islands?) after installing latest tzdata

\egrep -v '^#' /usr/share/zoneinfo/zone.tab | perl -anle 'print "setenv TZ $F[2]; echo $F[2]; date"' | sort | uniq

exit;

# mathematica format for sunrise/set data
perl -anle 'sub BEGIN {print "data={"} sub END {print "}"} unless (/^[0-9]/) {next;} print "{"; for $i (0..11) {$x=substr($_,4+11*$i,10);$x=~s/\s/,/;$x=~s/\s*$//; $x=~s/\-{4},\-{4}/0000,0000/; $x=~s/\*{4},\*{4}/2400,0000/; print "{$x},"}; print "},"' /home/barrycarter/BCGIT/db/srss-40n.txt

exit;

# (suggests) renaming files that make doesn't handle well
\ls | perl -nle '$x=$_; if (s/[^a-z0-9_\.\-\%\,]/_/isg) {print "mv \"$x\" $_"}'

exit;

# extracts words/definitions from Scrabble dictionary
# 45947 words
perl -0777 -nle 'while (s%<b>(\D*?)</b>.*?<br>\s*(.*?)\s*</p>%%is) {print "$1 $2\n"}' scrabble-dictionary.html


exit;

# if you tcpflow-dump when you enter a scribblar room, this downloads all the assets file (so you can delete them as needed)
perl -nle 'if (/\006G(.*?)\006/) {print "curl -O http://api.muchosmedia.com/brainwave/uploads/client_12/$1"}' *

exit;

# if you've downloaded your quora questions/answers main page, this gets the full questions/answers
# ACK: this does not cover updated questions sadly

perl -nle 'while (s/<a class="question_link" href="(.*?)"//i) {$url=$1; $file=$url; $file=~s/^.*\///isg; if (-f "/home/barrycarter/QUORA/$file") {next;}; print "curl -L -O $url"}' /home/barrycarter/Download/bc-questions.html /home/barrycarter/Download/bc-answers.html | sort | uniq 

exit;

# which surls still work?
surl -h | grep is.gd | perl -anle 'for $i (@F) {$i=~s/,//isg; print "echo test.com | surl -s $i > $i.out"}'

exit;

perl -e '@n=(0..9); @l=("a".."z","A".."Z"); for (1..8) {print $n[rand()*10];} print "-"; for(1..40) {print $l[rand()*52]}; print "\n"'

exit;

# obtain info from Z3950 server <h>(insert raucous laughter here)</h>

echo "f @attr 1=7 0425*\nshow" | yaz-client clas.caltechu:210/INNOPAC

exit;

# temp.temp contains elec readings, this spits them out properly
perl -anle 'use Date::Parse; print str2time("2012-06-03 $F[0] MDT")," ",$F[1]' ~/temp.temp

exit;

# I downloaded a bunch of mp3s from freesubliminals.com, but didn't
# note down which mp3 was supposed to do what; this uses archive.org
# to partially reconstruct what I have (manually downloaded the
# various category pages from
# http://web.archive.org/web/20071105010424/http://www.freesubliminals.com/index.php/2007/inspiring-article-ambitiously-pursuing-your-own-self-direction/
# first

# ran command below "exit" first, then ran:
# nothing I want ends in a / or /#postcomment or xmlrpc

grep -h href take1-*.html | perl -nle 's%/\#.*?$%%; /href="(.*?)"/; unless ($1) {next;}; print "curl -L -O $1"' | egrep -v '/$|xmlrpc|javascript' | sort | uniq

exit;

grep -h free-subliminal-mp3 *.html | sort | uniq | perl -nle '$n++; /href="(.*?)"/; print "curl -L -o take1-$n.html $1"'

exit;

# on Mac, extract audio from mp4/mpg to WAV

\ls | fgrep -v '.wav' | perl -nle 'print qq%"/Applications/MPlayer OSX.app/Contents/Resources/External_Binaries/mplayer.app/Contents/MacOS/mplayer" -ao "pcm:fast:file=$_.wav" -vo null -vc null "$_"%'

exit;

# speed up MP3s pointlessly (in a way that can be piped to parallel safely)
\ls *.mp3 | perl -nle 's/\.mp3$//; print "/usr/bin/mplayer -ao \47pcm:fast:file=/mnt/usbext/mp3/FAST/$_.wav\47 \47$_.mp3\47; sox \47/mnt/usbext/mp3/FAST/$_.wav\47 \47/mnt/usbext/mp3/FAST/$_-temp.wav\47 tempo 1.5 norm; lame \47/mnt/usbext/mp3/FAST/$_-temp.wav\47 \47/mnt/usbext/mp3/FAST/$_-fast.mp3\47"'

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

# better moonrise/set
echo "SELECT event, SUBSTR(REPLACE(TIME(time), ':',''),1,4) AS stime,(strftime('%s',DATE(time))-strftime('%s', DATE('now')))/86400 AS dist FROM abqastro WHERE event IN ('MR','MS') AND ABS(dist)<=1 ORDER BY time;" | sqlite3 /home/barrycarter/BCGIT/db/abqastro.db

# WHERE DATE(time) IN (DATE('now','localtime'), DATE('now','localtime', '+1 day')) AND event='MS' ORDER BY time LIMIT 1;" 

exit;

# last 60 days
perl -le 'use POSIX; for $i (0..60) {$now=time()-$i*86400; print strftime("%Y%m%d",localtime($now))}'

exit;



