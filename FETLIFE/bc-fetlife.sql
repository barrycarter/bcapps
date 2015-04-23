-- schema for FetLife db

CREATE TABLE kinksters (
 id INT, screenname TEXT, thumbnail TEXT, age INT, gender VARCHAR(10),
 role TEXT, loc1 TEXT, loc2 TEXT, page INT, scrape_time DATETIME
);

CREATE INDEX i1 ON kinksters(screenname);
CREATE INDEX i2 ON kinksters(age);
CREATE INDEX i3 ON kinksters(gender);
CREATE INDEX i4 ON kinksters(role);
CREATE INDEX i5 ON kinksters(loc1);
CREATE INDEX i6 ON kinksters(loc2);

.separator ,
.import /home/barrycarter/FETLIFE/20150418-FETLIFE/fetlife-user-list.csv kinksters

