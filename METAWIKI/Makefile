all: pbs-cl.txt /tmp/pbs-triples.db
pbs-cl.txt: /mnt/extdrive/GOCOMICS/pearlsbeforeswine/CHARLIST/* /home/barrycarter/BCGIT/METAWIKI/bc-pbs-cl.pl Makefile
	/home/barrycarter/BCGIT/METAWIKI/bc-pbs-cl.pl
# this is a terrible use of a Makefile
/tmp/pbs-triples.db: pbs.txt Makefile /home/barrycarter/BCGIT/METAWIKI/bc-meta-pbs.pl pbs-cl.txt
	/home/barrycarter/BCGIT/METAWIKI/bc-meta-pbs.pl
