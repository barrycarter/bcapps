# testing only

# bar := $(egrep -v '^#' /home/barrycarter/BCGIT/BRIGHTON/mounts.txt | perl -anle 'print "$F[0]/$F[1]-converted.txt"')

bar=$(egrep -v '^#' /home/barrycarter/BCGIT/BRIGHTON/mounts.txt)

bar=hello

bar="hello there"

# this fails amusingly because date outputs colons!

bar := $(shell date)

bar := $(shell date +%s)

bar=$(shell date +%s)

bar=$(shell egrep -v '^\#' /home/barrycarter/BCGIT/BRIGHTON/mounts.txt)

bar=$(shell egrep -v ^\# /home/barrycarter/BCGIT/BRIGHTON/mounts.txt)

bar=$(shell egrep -v ^\# /home/barrycarter/BCGIT/BRIGHTON/mounts.txt | perl -anle 'print "$$F[0]/$$F[1]-converted.txt"')

bar=$(shell egrep -v '^\#|^$$' /home/barrycarter/BCGIT/BRIGHTON/mounts.txt | perl -anle 'print "$$F[0]/$$F[1]-converted.txt"')

# bar=$(egrep -v '^\#' /home/barrycarter/BCGIT/BRIGHTON/mounts.txt | perl -anle 'print "\$F[0]/\$F[1]-converted.txt"')

foo: ${bar}
	echo arg
