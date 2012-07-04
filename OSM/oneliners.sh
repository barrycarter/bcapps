# aliases below just to speed things up a bit

# add the handful of addresses I've misses several times (BERN pincode
# is repeated many times, so don't try to catch it)

grep "'pin'" /tmp/abqaddresses-1-500000.xml | perl -nle '/v=.(.*?). \//; print $1' | sort | uniq | egrep -v '^BERN$' | fgrep -f - /tmp/abqsortbypin.txt | tee /tmp/abqsortbypin2.txt;: then replace abqsortbypin.txt by abqsortbypin2.txt

exit;

# add addresses 500 at a time (I realize I'll have problems at 50K addresses)

perl -le 'for ($i=501; $i<=255000; $i+=500) {$j=$i+499; print "bc-parse-addr.pl --changesetid=12101666 --chunkstart=$i --chunkend=$j --debug"}'

exit;

# check that my edits made it in
alias osm1 "curl -o /tmp/epi.txt 'http://api.openstreetmap.org/api/0.6/map/?bbox=2.71,3.14,2.72,3.15'; curl -o /tmp/pie.txt 'http://api.openstreetmap.org/api/0.6/map/?bbox=3.14,2.71,3.15,2.72'"

# tries to create a changeset
alias osm2 "curl -vv -n -d @test2.txt -XPUT http://api.openstreetmap.org/api/0.6/changeset/create |& tee /tmp/out2.txt"

# adds to a given changeset?
alias osm4 "curl -vv -n -d @test4.txt -XPOST http://api.openstreetmap.org/api/0.6/changeset/12048085/upload"

# deletes specified node (not working)
alias osm3 'curl -vv -d <osm><node id=\!*/></osm> -n -XDELETE http://api.openstreetmap.org/api/0.6/node/\!* |& tee /tmp/out-delete.txt'


exit;

# obtains deeper info on ABQ businesses, from the bzip'd results of step 1
bzfgrep -h ID=FA *.bz2 | perl -nle '/id=(.*?)"/i; print "curl -o $1 \47http://falcon.cabq.gov/envhealth/Details.asp?ID=$1\47"' | sort | uniq > runme.par

exit;

# downloads ABQ business data (step 1)
# the bzipped output of the concat of this is in data/firstrun.html.bz2

perl -le 'for(0..6049) {$x=$_*10; print "curl -o $x.out \47http://falcon.cabq.gov/envhealth/Results.asp?BusinessName=&StreetName=&StreetNumber=&StreetQuad=&ZipCode=&submit=Search&offset=$x\47"}'

exit;

# send two node changeset for testing
# got back 1787592359

curl -vv -n -d @test1.txt -XPUT http://api.openstreetmap.org/api/0.6/node/create |& tee /tmp/out2.txt

exit;

# request changeset (note my username/password is in ~/.netrc)
# got back 11897676

curl -vv -n -d '<osm><changeset /></osm>' -XPUT http://api.openstreetmap.org/api/0.6/changeset/create |& tee /tmp/out1.txt

exit;

