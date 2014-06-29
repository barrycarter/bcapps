-- Miscellaneous helpful SQLite3 queries on /tmp/pbs-triples.db

-- characters without species (usually an error)

SELECT t1.source, t2.target FROM 
 triples t1 LEFT JOIN triples t2 ON
 (t1.source = t2.source AND t2.k='species') WHERE 
t1.k = 'class' AND t1.target = 'character' AND t2.target IS NULL;


-- all strips where Rat appears; the inverse of this (via fgrep -vf) =
-- where Rat does not appear, or, more likely, where I haven't created a
-- character list yet

-- the page-date.gif format is used for comparison with the GIF list

.output /tmp/pbs-with-rat.txt
SELECT DISTINCT("page-"||source||".gif") FROM triples
 WHERE k="character" AND v="Rat";

.output /tmp/pbs-with-pig.txt
SELECT DISTINCT("page-"||source||".gif") FROM triples
 WHERE k="character" AND v="Pig";

.output /tmp/pbs-with-zebra.txt
SELECT DISTINCT("page-"||source||".gif") FROM triples
 WHERE k="character" AND v="Zebra";

.output /tmp/pbs-with-lemmings.txt
SELECT DISTINCT("page-"||source||".gif") FROM triples
 WHERE k="character" AND v="Lemmings";

.output /tmp/pbs-with-larry.txt
SELECT DISTINCT("page-"||source||".gif") FROM triples
 WHERE k="character" AND v="Larry";

.output /tmp/pbs-with-lgd.txt
SELECT DISTINCT("page-"||source||".gif") FROM triples
 WHERE k="character" AND v="Guard Duck";

.output /tmp/pbs-with-goat.txt
SELECT DISTINCT("page-"||source||".gif") FROM triples
 WHERE k="character" AND v="Goat";

.output /tmp/pbs-with-pastis.txt
SELECT DISTINCT("page-"||source||".gif") FROM triples
 WHERE k="character" AND v="Stephan Pastis";

.output /tmp/pbs-with-whale.txt
SELECT DISTINCT("page-"||source||".gif") FROM triples
 WHERE k="character" AND v="Whale";



