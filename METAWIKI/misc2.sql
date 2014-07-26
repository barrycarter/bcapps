-- checks/fixes things for bc-pbs3.pl

-- assign classes
-- you're a character if you're on either side of a father/mother type relation
-- also target=character if "strip,character|deaths|kille(re),target"
-- also source=character if "source,species|profession,target"

INSERT INTO triples
 SELECT DISTINCT source, 'class', 'character', 'misc2.sql'
 FROM triples WHERE relation IN (
 'cousin', 'uncle', 'aunt', 'husband', 'brother', 'ex-husband',
 'grandfather', 'mother', 'niece', 'sister', 'son', 'wife',
 'neighbor', 'girlfriend', 'boss', 'friend', 'father', 'half-brother',
 'pet', 'roommate', 'date', 'grandmother', 'species', 'profession', 'killee',
 'hobby', 'aka'
);

INSERT INTO triples
 SELECT DISTINCT target, 'class', 'character', 'misc2.sql'
 FROM triples WHERE relation IN (
 'cousin', 'uncle', 'aunt', 'husband', 'brother', 'ex-husband',
 'grandfather', 'mother', 'niece', 'sister', 'son', 'wife',
 'neighbor', 'girlfriend', 'boss', 'friend', 'father', 'half-brother',
 'pet', 'roommate', 'date', 'grandmother', 'deaths', 'killee'
);

INSERT INTO triples
 SELECT DISTINCT target, 'class', 'continuity', 'misc2.sql' FROM triples
WHERE source IN ('MULTIREF');

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

.quit
 

 

