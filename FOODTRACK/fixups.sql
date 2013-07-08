-- fixes myfoods.db from import-based problems

-- TODO: can I do these all at once?
UPDATE foods SET URL=REPLACE(URL,'%3A', ':');
UPDATE foods SET URL=REPLACE(URL,'%2F', '/');
UPDATE foods SET URL=REPLACE(URL,'%3F', '?');
UPDATE foods SET URL=REPLACE(URL,'%3D', '=');
UPDATE foods SET URL=REPLACE(URL,'%26', '&');
UPDATE foods SET URL=REPLACE(URL,'%28', '(');
UPDATE foods SET URL=REPLACE(URL,'%29', ')');


