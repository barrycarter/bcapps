-- Miscellaneous helpful SQLite3 queries on /tmp/pbs-triples.db

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




