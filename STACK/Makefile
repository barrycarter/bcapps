all: /home/barrycarter/bin/bc-solve-codereview-118091 /home/barrycarter/bin/bc-solve-codereview-118568 /home/barrycarter/bin/bc-solve-codereview-118568-orig /tmp/Main.class unsolved2.txt solved2.txt
/home/barrycarter/bin/bc-solve-codereview-118091: bc-solve-codereview-118091.c
	g++ bc-solve-codereview-118091.c -o /home/barrycarter/bin/bc-solve-codereview-118091 
/home/barrycarter/bin/bc-solve-codereview-118568: bc-solve-codereview-118568.c
	g++ bc-solve-codereview-118568.c -Wall -O2 -o /home/barrycarter/bin/bc-solve-codereview-118568
/home/barrycarter/bin/bc-solve-codereview-118568-orig: bc-solve-codereview-118568-orig.c
	g++ bc-solve-codereview-118568-orig.c -o /home/barrycarter/bin/bc-solve-codereview-118568-orig
/tmp/Main.class: Main.java
	javac -d /tmp/ Main.java
# put solved.txt and unsolved.txt into usable forms
unsolved2.txt: solved.txt
	egrep -v '^#|^$$' unsolved.txt > unsolved2.txt
solved2.txt: solved.txt
	egrep -v '^#|^$$' solved.txt > solved2.txt
