# shell one liners

perl -le 'use POSIX; for $i (0..60) {$now=time()-$i*86400; print strftime("%Y%m%d",localtime($now))}'

exit;

# better moonrise/set
echo "SELECT * FROM abqastro WHERE DATE(time) IN (DATE('now','localtime'), DATE('now','localtime', '+1 day')) AND event='MS' ORDER BY time LIMIT 1;" | sqlite3 /home/barrycarter/BCGIT/db/abqastro.db



