-- schema for FetLife db

CREATE TABLE kinksters (
 id INT, screenname TEXT, age INT, gender TEXT, role TEXT, city TEXT,
 state TEXT, country text, thumbnail TEXT, popnum INT, popnumtotal INT,
 source TEXT, mtime INT);

-- indexes for MySQL

CREATE INDEX i1 ON kinksters(screenname(20));
CREATE INDEX i2 ON kinksters(age);
CREATE INDEX i3 ON kinksters(gender(10));
CREATE INDEX i4 ON kinksters(role(10));
CREATE INDEX i5 ON kinksters(city(10));
CREATE INDEX i6 ON kinksters(state(10));
CREATE INDEX i7 ON kinksters(country(10));

-- indexes for SQLite3

CREATE INDEX i1 ON kinksters(screenname);
CREATE INDEX i2 ON kinksters(age);
CREATE INDEX i3 ON kinksters(gender);
CREATE INDEX i4 ON kinksters(role);
CREATE INDEX i5 ON kinksters(city);
CREATE INDEX i6 ON kinksters(state);
CREATE INDEX i7 ON kinksters(country);

-- import for MySQL

LOAD DATA LOCAL INFILE '/home/barrycarter/20150506/fetlife-users-20150503.csv'
INTO TABLE kinksters FIELDS TERMINATED BY ',';

--import for SQLite3 (due to error)

ALTER TABLE kinksters ADD COLUMN bogus;

.separator ","
.import /sites/test/FETLIFE/fetlife-users-20150503.csv kinksters

