# exports the USDA nutritional database (http://www.ars.usda.gov/Services/docs.htm?docid=22113) from Microsoft Access to SQLite3 using mdbtools (I could've used the ASCII version too)
cd /home/barrycarter/20120923/ACCESS; mdb-schema sr24.mdb >! schema.txt; rm -f data.txt; mdb-tables sr24.mdb | perl -anle 'for $i (@F) {print "mdb-export -I sr24.mdb $i >> data.txt"}' | sh
