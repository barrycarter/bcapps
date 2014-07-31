-- checks/fixes things for bc-pbs3.pl

-- TODO: drop psuedo-temporary tables and vacuum
-- TODO: renaming of "Bob 20020209 (human)" must occur semi-early
-- very lazy way to create 'relatives' table

DROP TABLE IF EXISTS relatives;
CREATE TABLE relatives AS SELECT DISTINCT relation FROM triples WHERE 
 relation IN (
 'cousin', 'uncle', 'aunt', 'husband', 'brother', 'ex-husband',
 'grandfather', 'mother', 'niece', 'sister', 'son', 'wife',
 'neighbor', 'girlfriend', 'boss', 'friend', 'father', 'half-brother',
 'pet', 'roommate', 'date', 'grandmother', 'killee', 'killer', 'ex-employee'
);

-- get rid of inapproptiate {{wp|things}} (except OK in some places)

UPDATE triples SET target= REPLACE(REPLACE(target,"{{wp|",""),"}}","")
WHERE target LIKE '%{{%}}%' AND relation IN 
 ('storyline', 'cameo', 'location', 'aka');

-- MULTIREF: assign class to MULTIREF
INSERT INTO triples
SELECT target, 'class', 'continuity', 'multiref'
FROM triples WHERE source LIKE 'MULTIREF%' AND relation='title';

-- MULTIREF: assign properties to title of multiref
INSERT INTO triples
SELECT t1.target, t2.relation, t2.target, 'multiref'
FROM triples t1 JOIN triples t2 ON (t1.source = t2.source) WHERE
t1.source LIKE 'MULTIREF%' AND t1.relation='title' AND t2.relation!='title';

-- all done w multiref
DELETE FROM triples WHERE source LIKE 'MULTIREF%';

-- assign classes
-- you're a character if you're on either side of a father/mother type relation
-- also target=character if "strip,character|deaths|kille(re),target"
-- also source=character if "source,species|profession,target"

-- TODO: this is a hack; if there is info given about you on date, you
-- are a character for that date

-- NOTE: Strips can have "location" too, so can't include "location" below

INSERT INTO triples
 SELECT DISTINCT datasource, 'character', source, 'misc2.sql:L45'
-- SELECT DISTINCT source, 'class', 'character', 'misc2.sql'
 FROM triples WHERE relation IN (SELECT * FROM relatives) OR
 relation IN ('species', 'profession', 'hobby', 'aka')
;

INSERT INTO triples
 SELECT DISTINCT datasource, 'character', target, 'misc2.sql:L52'
-- SELECT DISTINCT target, 'class', 'character', 'misc2.sql'
 FROM triples WHERE relation IN (SELECT * FROM relatives) OR
 relation IN ('deaths')
;

INSERT INTO triples
 SELECT DISTINCT source, 'class', 'strip', 'misc2.sql' FROM triples WHERE
 relation IN ('hash');

INSERT INTO triples
SELECT DISTINCT source, 'class', 'book', 'misc2.sql' FROM triples WHERE
 relation IN ('isbn');

INSERT INTO triples
SELECT DISTINCT target, 'class', relation, 'misc2.sql' FROM triples WHERE
 relation IN (
  'book', 'aka', 'storyline', 'category', 'cameo', 'location', 'newspaper',
  'character'
);

INSERT INTO triples
SELECT DISTINCT target, 'class', 'group', 'misc2.sql' FROM triples WHERE
 relation IN ('member');

-- for strips, find next and previous date (this is cheating slightly,
-- assuming strips are available daily, when they are not)

INSERT INTO triples
SELECT source, 'prev', DATE(source, '-1 day'), 'misc2.sql'
FROM triples WHERE relation='class' AND target='strip';

INSERT INTO triples
SELECT source, 'next', DATE(source, '+1 day'), 'misc2.sql'
FROM triples WHERE relation='class' AND target='strip';

-- find/fix cases where source/target is an aka -- this table is perm
-- just so I can do "sqlite3 db < misc2.sql" and re-open db to run
-- queries

DROP TABLE IF EXISTS aka;
CREATE TABLE aka AS
 SELECT source, target FROM triples WHERE relation='aka';

-- storylines can be named for aliases

INSERT INTO triples
SELECT a1.source, t1.relation, t1.target, t1.datasource
 FROM triples t1 JOIN aka a1 ON
 (t1.source = a1.target AND t1.target NOT IN 
('aka', 'storyline', 'reference_name'));

DELETE FROM triples WHERE source IN (SELECT target FROM aka) AND
 target NOT IN ('aka', 'storyline', 'reference_name');

INSERT INTO triples
SELECT t1.source, t1.relation, a1.source, t1.datasource 
 FROM triples t1 JOIN aka a1 ON
 (t1.target = a1.target AND t1.relation NOT IN 
('aka', 'storyline', 'reference_name'));

DELETE FROM triples WHERE target IN (SELECT target FROM aka) AND
 relation NOT IN ('aka', 'storyline', 'reference_name');

-- species assignment (may need Perl for this [nope!])

INSERT INTO triples
SELECT DISTINCT t1.source, 'species',  SUBSTR(
 t1.source,INSTR(t1.source, "(")+1, 
 INSTR(t1.source, ")") - INSTR(t1.source, "(") - 1
), t1.datasource
FROM triples t1 LEFT JOIN triples t2 ON
 (t1.source = t2.source AND t2.relation = 'species')
 WHERE t1.relation='class' AND t1.target='character' AND t2.relation IS NULL 
 AND t1.source LIKE '%(%'
;

-- forward and reverse relations (shouldn't REALLY need this, but...)

INSERT INTO triples
SELECT DISTINCT t1.source, 
'relationship', '[['||t1.target||']]'||' ('||t1.relation||')', t1.datasource
 FROM triples t1 JOIN relatives r1 ON (t1.relation = r1.relation)
;

INSERT INTO triples
SELECT DISTINCT t1.target, 
'relationship', '[['||t1.source||']]'||'''s '||t1.relation, t1.datasource
 FROM triples t1 JOIN relatives r1 ON (t1.relation = r1.relation)
;

-- and get rid of the now unnecessary relations
-- commenting this out for testing purposes (it's harmless)
-- DELETE FROM triples WHERE relation IN (SELECT * FROM relatives);

-- this could be divined semantically but...

DROP TABLE IF EXISTS charcount;
CREATE TABLE charcount AS 
SELECT COUNT(DISTINCT(source)) AS count, target FROM triples
 WHERE relation='character' GROUP BY target;

INSERT INTO triples
SELECT MIN(source), 'event', '1st appearance: [['||c1.target||']]','misc2.sql'
FROM triples t1 JOIN charcount c1 ON 
 (t1.target = c1.target AND t1.relation='character')
WHERE c1.count > 10 GROUP BY c1.target;

INSERT INTO triples
SELECT source, 'event', 'Death: [['||c1.target||']]','misc2.sql'
FROM triples t1 JOIN charcount c1 ON
 (t1.target = c1.target AND t1.relation='deaths')
WHERE c1.count>10 GROUP BY c1.target;

SELECT "USING QUIT TO QUIT";
.quit

-- items without classes (except those that are allowed not to have classes)

-- if you are the target of class/hash/gender/etc, no class required
SELECT DISTINCT * FROM triples t1 LEFT JOIN triples t2 ON (
t1.target = t2.source AND t2.relation='class'
) WHERE t1.relation NOT IN (
 'class', 'hash', 'gender', 'isbn', 'meta', 'notes', 'species', 'profession',
 'char_list_complete', 'description', 'subspecies', 'event',
 'has_additional_characters', 'has_anon_characters', 'orientation', 
 'religion', 'hobby'
) AND t1.relation NOT LIKE '%_deaths' AND t2.source IS NULL;

SELECT DISTINCT * FROM triples t1 LEFT JOIN triples t2 ON (
t1.source = t2.source AND t2.relation='class')
WHERE t1.source NOT IN ('MULTIREF') AND t2.source IS NULL;

 

 

