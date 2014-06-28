-- Miscellaneous helpful SQLite3 queries on /tmp/pbs-triples.db

-- List of mathematical relations that are considered "social
-- relations", meaning that both sides of the relation are
-- characters. Only need this temporarily

CREATE TEMPORARY TABLE relations (relation);

INSERT INTO relations VALUES ('cousin');
INSERT INTO relations VALUES ('uncle');
INSERT INTO relations VALUES ('aunt');
INSERT INTO relations VALUES ('husband');
INSERT INTO relations VALUES ('brother');
INSERT INTO relations VALUES ('ex-husband');
INSERT INTO relations VALUES ('grandfather');
INSERT INTO relations VALUES ('mother');
INSERT INTO relations VALUES ('niece');
INSERT INTO relations VALUES ('sister');
INSERT INTO relations VALUES ('son');
INSERT INTO relations VALUES ('wife');
INSERT INTO relations VALUES ('neighbor');
INSERT INTO relations VALUES ('girlfriend');
INSERT INTO relations VALUES ('boss');
INSERT INTO relations VALUES ('friend');
INSERT INTO relations VALUES ('father');
INSERT INTO relations VALUES ('half-brother');
INSERT INTO relations VALUES ('pet');
INSERT INTO relations VALUES ('roommate');
INSERT INTO relations VALUES ('date');
INSERT INTO relations VALUES ('grandmother');

-- source/deaths/target -> source/character/target (same datasource)

INSERT OR IGNORE INTO triples
SELECT source,'character',target,datasource FROM triples WHERE k='character';

-- source/(social relation)/target means both source and target
-- "appear in" datasource

SELECT datasource, 'character', source FROM triples WHERE 
 k IN (SELECT * FROM relations);

SELECT datasource, 'character', target FROM triples WHERE 
 k IN (SELECT * FROM relations);









-- class determination

-- if source/character/target target is a character

INSERT OR IGNORE INTO triples
SELECT target, 'class', 'character', '' FROM triples WHERE k = 'character';

-- if source/(social relation)/target both source/target are characters

INSERT OR IGNORE INTO triples
SELECT target, 'class', 'character', '' FROM triples WHERE k IN
 (SELECT * FROM relations);

INSERT OR IGNORE INTO triples
SELECT source, 'class', 'character', '' FROM triples WHERE k IN
 (SELECT * FROM relations);









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



