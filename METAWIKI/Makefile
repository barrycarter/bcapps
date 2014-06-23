all: pbs-cl.txt /tmp/pbs-triples.db /tmp/pbs-with-rat.txt /tmp/pbs-with-pig.txt
/tmp/pbs-with-rat.txt /tmp/pbs-with-pig.txt: /tmp/pbs-triples.db Makefile misc.sql
	sqlite3 /tmp/pbs-triples.db < misc.sql
pbs-cl.txt: /mnt/extdrive/GOCOMICS/pearlsbeforeswine/CHARLIST/* bc-pbs-cl.pl Makefile
	./bc-pbs-cl.pl
# this is a terrible use of a Makefile
/tmp/pbs-triples.db: pbs.txt Makefile bc-meta-pbs.pl pbs-cl.txt bc-meta-referata.pl
	./bc-meta-pbs.pl;./bc-meta-referata.pl
