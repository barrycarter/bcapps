all: phrases.txt /tmp/playground.class
# compile playground.java in /tmp (to run: "java -cp /tmp playground")
/tmp/playground.class: playground.java
	javac -d /tmp playground.java
# this just makes it easier to fgrep -vf
# can't get egrep -v '^
phrases.txt: bots.txt Makefile
	egrep -v '^#' bots.txt | egrep '[a-z0-9_]' > phrases.txt
