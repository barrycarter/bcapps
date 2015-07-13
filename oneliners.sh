# shell one liners

# (suggests) renaming files that make doesn't handle well (removes spaces)
\ls | perl -nle '$x=$_; if (s/[^a-z0-9_\.\-\%\,]/_/isg) {print "mv \"$x\" $_"}'

exit;

# find PNG files that haven't been tesseract'd and tesseract them
# (note: using .tess since I use .txt for feh annotations)

# other extensions: .jfx (for JFAX TIFF files), .tif (TIFFs), .xif (more TIFFs)

find . -iname '*.png' | fgrep -v /.xvpics/ | perl -nle 'unless (-f "$_.tess.txt") {print "tesseract $_ $_.tess"}'

exit;


# most indexed documents in recollindex (useful to trim out useless docs)

fgrep '[/' recollindex.log | perl -nle '/\[(.*?)\]/; $x=$1; $x=~s/\|.*$//; print $x' | sort | uniq -c | sort -nr | tee /tmp/results.txt

exit; 

# copy files to a remote location, but only 500 per dir (because
# target program that imports them doesn't like large file lists)

perl -nle 'if ($count++%100==0) {print "mkdir /remote/",++$dir;} print "cp \"$_\" /remote/$dir/$count.pdf"'

exit; 

# every possible transcoding with the hope that one of them works w/
# Archos (for H264 videos which are not natively supported w/o
# non-free plugin)

perl -le 'for $v ("mp4v", "mpgv", "div1", "div2", "div3", "h263", "i263", "wmv1", "wmv2", "mjpg", "mjpb") {for $a ("mpga", "a52", "ac3", "vorb") {for $m ("avi", "ogg", "ps", "ts") {print "echo $m-$a-$v; date; vlc -I dummy input.mp4 --sout=\47#transcode:{vcodec=$v,acodec=$a}:std{access=file,mux=$m,dst=\"000-test-$m-$a-$v\"}\47 vlc://quit; date"}}}';

exit; 

# list of files on extdrive, with filename separated from full
# filename (so I can join against files in /mnt/sshfs/ with the goal
# of getting the same files in the same directories to avoid confusing
# rsync)

# will need to sort these before using "join" of course

perl -nle 's%^.*?/%/%;$x=$_;s%^.*/%%; print "$_\0$x"' /mnt/extdrive/extdrive-files.txt > extdrive-file-filename.txt &

perl -nle 's%^.*?/%/%;$x=$_;s%^.*/%%; print "$_\0$x"' /mnt/sshfs/bcmac-files.txt > bcmac-file-filename.txt &

exit; 

# dump DST change dates in yyyymmdd format
zdump -v MST7MDT | fgrep ' MST'| perl -nle 'use POSIX; use Date::Parse; print "LINE: $_"; s/MST7MDT\s+//;s/ \=.*$//; print strftime("%Y%m%d DST",localtime(str2time($_)))'

# zdump -v MST7MDT | perl -nle 's/^.*\=\s+//; s/\sisdst.*$//; print "date \"+%Y%m%d DST\" -d \"$_\""'

exit;

# given output of "ls -l | sort -k7" (files in size order), running
# total of file size to see how many files use up lots of space (in gigs)

perl -anle '$count++; $sum+=$F[6]/1e9; print "$count $sum"'

exit;

# from TED (the energy detective) device, get per day total (after
# bzcat and sort and uniq from raw data)

perl -F, -anle '$F[1]=~s/\s.*//; $tot{$F[1]}+=$F[2]; sub END {for $i (sort keys %tot) {print "$i $tot{$i}";}}' allseconds-sorted.txt

exit; 

# un7z all stackexchange stuff

\ls *.7z | perl -nle 's/\.7z//; print "7z x -o$_ $_.7z"' | tee /tmp/un7z.sh

exit; 

# open all urls in se-sites.txt in browser, one tab per site
egrep -v '^#' /home/barrycarter/se-sites.txt | xargs -n 1 -i /root/build/firefox/firefox -remote 'openURL({})'

exit; 

# first thursday of upcoming months

perl -le 'use Date::Parse; for $y (2014..2029) {for $m ("01".."12") {$t = 8-(str2time("$y${m}01 00:00:00 UTC")/86400)%7; if ($t==8) {$t=1;}; print "$y${m}0$t"}}'

exit;

# greps for gmail addresses in zip files (kind of)

unzip -c facebook-barrycarter121.zip | perl -pnle 's/(<.*?>)/$1\n/g' | grep gmail

exit;

# lists tuesdays ("date -d 'next Tuesday 12:00:00' +%s" to start) and
# later wednesdays

perl -le 'use Date::Parse; use POSIX; for ($i=1409076000+86400;$i<=1409076000+15*366*86400; $i+=86400*7) {print strftime("%Y%m%d", localtime($i));}'

exit;

# filters stuff I want from calendar in correct format

gcal -u @/home/barrycarter/BCGIT/ASTRO/gcal-options.txt 2016 | perl -nle '/^(.*?)\s{2,}[\+\-]\s+(\d{8})/||warn("BAD: $_"); my($e,$d)=($1,$2); $e=~s/\s*\(.*?\)\s*$//; $e=~s/\47//g; $e=~s/\s*Day\s*/ /; print "$d $e"' | egrep -vf /home/barrycarter/20140726/nocal.txt | sort | uniq

# gcal @/home/barrycarter/BCGIT/ASTRO/gcal-options.txt | perl -F"\s\s+" -anle '$F[0]=~s/\s*\(.*?\)\s*//; print "$F[2] $F[1]"'

exit;

# list all pages on my wiki semi-manually

curl -o out5.txt 'http://pbs3.referata.com/w/api.php?action=query&generator=allpages&gaplimit=500&prop=revisions&rvprop=timestamp|user&format=xml&namespace=0&gapcontinue=2007-06-04'

exit;

curl -o out1.txt 'http://pbs3.referata.com/w/api.php?action=query&generator=allpages&gaplimit=500&prop=revisions&rvprop=timestamp|user&format=xml&namespace=0'

exit; 

# from http://www.okcupid.com/messages?folder=2 prints users I've sent
# mail to (note: be sure to scroll all the way down, and repeat if
# there are multiple pages); 
# sample usage: 
# ~/BCGIT/oneliners.sh < ~/Download/messages.html | tee ~/okcupid-barrycarter-hide-sent.txt
# where ~ is /home/barrycarter

# list sundays for Pearls Before Swine
perl -le 'use Date::Parse; use POSIX; $st = str2time("2002-01-13"); for $i (1..52*13) {$st+=86400*7; print strftime("page-%Y-%m-%d.gif", gmtime($st))}'

exit;

perl -anle 'if (m%/profile/(.*?)\?cf=messages%) {print $1;}' | sort | uniq

exit;

# biggest map of USA google maps will give me (though I might end up
# gluing smaller maps together) [will actually probably use OSM maps]

curl -o maptest10.png 'http://maps.googleapis.com/maps/api/staticmap?center=39,-111&zoom=5&size=640x640&scale=2&maptype=hybrid&sensor=false'

curl -o maptest7.png 'http://maps.googleapis.com/maps/api/staticmap?center=37,-80.5&zoom=5&size=640x640&scale=2&maptype=roadmap&sensor=false'

exit;

# symlinks all sqlite dbs in all my firefox profiles and changes
# extension to db (so Makefile.sqlite can handle them)
\ls -1 ~/.mozilla/firefox/*/*.sqlite | perl -nle '$x=$_; s/^.*\/firefox\/+//; s/\.sqlite/.db/; s/\//-/isg; print "ln -s $x $_"'

exit;

# random lat/lon/alt in world [alt in m, others in degrees] for
# stellarium/etc lunar testing

perl -le 'printf("%0.4f,%0.4f,%d\n",rand(360)-180,rand(180)-90,rand(10000))';

exit;

# people who ive dealt with but were never pinged (for completeness)
# I add these to toping.txt and then ping them (auto-exclude for repeats)

\egrep -i '^From:|^Reply-to: ' ~/mail/leonard.zeptowitz ~/mail/leonard.zeptowitz.has.replied | perl -nle 'if (/<(.*?\@.*?)>/) {print lc($1)}' | sort | uniq | grep -v zeptowitz

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



