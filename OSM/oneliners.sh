curl -vv -n -d @test2.txt -XPUT http://api.openstreetmap.org/api/0.6/changeset/create |& tee /tmp/out2.txt

exit;

# check that my edits made it in
curl -o /tmp/epi.txt 'http://api.openstreetmap.org/api/0.6/map/?bbox=2.71,3.14,2.72,3.15'

curl -o /tmp/pie.txt 'http://api.openstreetmap.org/api/0.6/map/?bbox=3.14,2.71,3.15,2.72'

exit;

# send two node changeset for testing
# got back 1787592359

curl -vv -n -d @test1.txt -XPUT http://api.openstreetmap.org/api/0.6/node/create |& tee /tmp/out2.txt

exit;

# request changeset (note my username/password is in ~/.netrc)
# got back 11897676

curl -vv -n -d @getchangesetid.txt -XPUT http://api.openstreetmap.org/api/0.6/changeset/create |& tee /tmp/out1.txt

exit;

