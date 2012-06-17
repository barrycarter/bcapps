# aliases below just to speed things up a bit

# downloads ABQ business data (step 1)

perl -le 'for(0..6049) {$x=$_*10; print "curl -o $x.out \47http://falcon.cabq.gov/envhealth/Results.asp?BusinessName=&StreetName=&StreetNumber=&StreetQuad=&ZipCode=&submit=Search&offset=$x\47"}'

exit;

# check that my edits made it in
alias osm1 "curl -o /tmp/epi.txt 'http://api.openstreetmap.org/api/0.6/map/?bbox=2.71,3.14,2.72,3.15'; curl -o /tmp/pie.txt 'http://api.openstreetmap.org/api/0.6/map/?bbox=3.14,2.71,3.15,2.72'"

# tries to create a changeset
alias osm2 "curl -vv -n -d @test2.txt -XPUT http://api.openstreetmap.org/api/0.6/changeset/create |& tee /tmp/out2.txt"

# adds to a given changeset?
alias osm4 "curl -vv -n -d @test4.txt -XPOST http://api.openstreetmap.org/api/0.6/changeset/11899798/upload"

# deletes specified node (not working)
alias osm3 'curl -vv -d <osm><node id=\!*/></osm> -n -XDELETE http://api.openstreetmap.org/api/0.6/node/\!* |& tee /tmp/out-delete.txt'

exit;

# send two node changeset for testing
# got back 1787592359

curl -vv -n -d @test1.txt -XPUT http://api.openstreetmap.org/api/0.6/node/create |& tee /tmp/out2.txt

exit;

# request changeset (note my username/password is in ~/.netrc)
# got back 11897676

curl -vv -n -d @getchangesetid.txt -XPUT http://api.openstreetmap.org/api/0.6/changeset/create |& tee /tmp/out1.txt

exit;

