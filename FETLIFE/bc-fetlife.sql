-- schema for FetLife db (both MySQL and SQLite3)

CREATE TABLE kinksters (
 id INT, screenname TEXT, age INT, gender TEXT, role TEXT, city TEXT,
 state TEXT, country text, thumbnail TEXT, popnum INT, popnumtotal INT,
 source TEXT, mtime INT, latitude DOUBLE, longitude DOUBLE);

-- indexes for MySQL

CREATE INDEX i0 ON kinksters(id);
CREATE INDEX i1 ON kinksters(screenname(20));
CREATE INDEX i2 ON kinksters(age);
CREATE INDEX i3 ON kinksters(gender(10));
CREATE INDEX i4 ON kinksters(role(10));
CREATE INDEX i5 ON kinksters(city(10));
CREATE INDEX i6 ON kinksters(state(10));
CREATE INDEX i7 ON kinksters(country(10));
CREATE INDEX i8 ON kinksters(latitude);
CREATE INDEX i9 ON kinksters(longitude);

-- indexes for SQLite3

CREATE INDEX i0 ON kinksters(id);
CREATE INDEX i1 ON kinksters(screenname);
CREATE INDEX i2 ON kinksters(age);
CREATE INDEX i3 ON kinksters(gender);
CREATE INDEX i4 ON kinksters(role);
CREATE INDEX i5 ON kinksters(city);
CREATE INDEX i6 ON kinksters(state);
CREATE INDEX i7 ON kinksters(country);
CREATE INDEX i8 ON kinksters(latitude);
CREATE INDEX i9 ON kinksters(longitude);

-- thumbnail view (SQLite3)

CREATE VIEW thumbs AS 
 SELECT "<img src='"||thumbnail||"'>" AS img,
 "<a href='https://fetlife.com/users/" || id || "' target='_blank'> "|| 
  screenname || "</a>" as link,
age, gender, role, city, state, country, popnum, popnumtotal
FROM kinksters;

-- thumbnail view (MySQL)

CREATE VIEW thumbs AS 
 SELECT CONCAT("<img src='",thumbnail,"'>") AS img,
 CONCAT("<a href='https://fetlife.com/users/",id,"' target='_blank'>",
  screenname,"</a>") as link,
age, gender, role, city, state, country, popnum, popnumtotal
FROM kinksters;

-- import for MySQL

LOAD DATA LOCAL INFILE 
'/mnt/extdrive/20150509/fetlife-users-20150519-with-lat-lon.csv'
INTO TABLE kinksters FIELDS TERMINATED BY ',';

--import for SQLite3 (due to error)

.separator ","
.import fetlife-users-20150507.csv kinksters

-- I actually imported using split because bc-daemon-checker kills of
-- sqlite3 if it runs too long (which really means I should allow for
-- temporary exceptions)

