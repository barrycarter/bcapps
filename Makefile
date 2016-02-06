all: phrases.txt /tmp/playground.class unsolved2.txt solved2.txt
# put solved.txt and unsolved.txt into usable forms
unsolved2.txt: solved.txt
	egrep -v '^#|^$$' unsolved.txt > unsolved2.txt
solved2.txt: solved.txt
	egrep -v '^#|^$$' solved.txt > solved2.txt
# compile playground.java in /tmp (to run: "java -cp /tmp playground")
/tmp/playground.class: playground.java
	javac -d /tmp playground.java
# this just makes it easier to fgrep -vf
# can't get egrep -v '^
phrases.txt: bots.txt Makefile
	egrep -v '^#' bots.txt | egrep '[a-z0-9_]' > phrases.txt
