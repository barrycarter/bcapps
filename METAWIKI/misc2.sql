-- for playground.pl, find "bad" things in triples

-- TODO: handle MULTIREFS!!! [[title::X]] [[notes::Y]] -> [[X::notes::Y]]?

SELECT * FROM triples t1 JOIN triples t2 ON (t1.target = t2.source)
 WHERE t1.relation='aka' AND t2.relation='aka';


