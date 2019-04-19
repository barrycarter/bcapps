all: phrases.txt /home/user/bin/bc-scanf-tests

/home/user/bin/bc-scanf-tests: bc-scanf-tests.c
	gcc -o /home/user/bin/bc-scanf-tests bc-scanf-tests.c

# this just makes it easier to fgrep -vf
# can't get egrep -v '^
phrases.txt: bots.txt Makefile
	egrep -v '^#' bots.txt | egrep '[a-z0-9_]' > phrases.txt
