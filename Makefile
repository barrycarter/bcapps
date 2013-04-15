all: phrases.txt /tmp/particleman
# this just makes it easier to fgrep -vf
# can't get egrep -v '^
phrases.txt: bots.txt Makefile
	egrep -v '^#' bots.txt | egrep '[a-z0-9_]' > phrases.txt
# intentionally making this in /tmp, no point in making here
/tmp/particleman: particleman.c Makefile
	gcc -lglut particleman.c -o /tmp/particleman
