-- schema for FetLife db

CREATE TABLE kinksters (
 id INT, screenname TEXT, age INT, gender TEXT, role TEXT, city TEXT,
 state TEXT, country text, thumbnail TEXT, popnum INT, popnumtotal INT,
 source TEXT, mtime INT);

CREATE INDEX i1 ON kinksters(screenname(20));
CREATE INDEX i2 ON kinksters(age);
CREATE INDEX i3 ON kinksters(gender(10));
CREATE INDEX i4 ON kinksters(role(10));
CREATE INDEX i5 ON kinksters(city(10));
CREATE INDEX i6 ON kinksters(state(10));
CREATE INDEX i7 ON kinksters(country(10));
