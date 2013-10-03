-- create the climate sqlite3 db
-- TODO: only 264 stations, so I am not happy

CREATE TABLE climate (
 metar TEXT, -- METAR code for site
 month INT, date INT, hour INT,
 num_obs INT, -- number of observations
 avg DOUBLE, -- average temperature in degrees Farenheit for month/day/hour
 m DOUBLE, -- slope of temperature over years (m in mx+b)
 b DOUBLE -- the constant b in the best fit line mx+b
);

.separator " "
.import climate.txt climate

CREATE INDEX i1 ON climate(metar);
CREATE INDEX i2 ON climate(month);
CREATE INDEX i3 ON climate(date);
CREATE INDEX i4 ON climate(hour);
CREATE INDEX i5 ON climate(avg);
CREATE INDEX i6 ON climate(m);
