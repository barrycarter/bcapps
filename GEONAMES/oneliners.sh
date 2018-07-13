# one off for https://opendata.stackexchange.com/questions/12988/data-for-all-lakes-on-earth

sqlite3 -header geonames.db 'SELECT g1.asciiname, g1.geonameid, g1.latitude, g1.longitude, g1.feature_code, REPLACE(g2.adminstring, ".00", "") AS country FROM geonames g1 LEFT JOIN geonames g2 ON (g1.admin0_code = g2.geonameid) WHERE g1.feature_code IN ("LK", "LKC", "LKI", "LKN", "LKNI", "LKO", "LKOI", "LKS", "LKSB", "LKSC", "LKSI", "LKSN", "LKSNI", "LKX", "RSV", "RSVI", "PND", "PNDI", "PNDN", "PNDNI", "PNDS", "PNDSF", "PNDSI", "PNDSN") ORDER BY g1.asciiname;'

