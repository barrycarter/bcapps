# creates executables from C code
all: /home/barrycarter/bin/seps /home/barrycarter/bin/j2d /home/barrycarter/bin/gfevnt /home/barrycarter/bin/gfuds /home/barrycarter/bin/gfudb
/home/barrycarter/bin/seps: bc-find-under6.c
	gcc -I /home/barrycarter/SPICE/cspice/include bc-find-under6.c -o /home/barrycarter/bin/seps /home/barrycarter/SPICE/cspice/lib/cspice.a -lm
/home/barrycarter/bin/j2d: bc-j2d.c
	gcc -I /home/barrycarter/SPICE/cspice/include bc-j2d.c -o /home/barrycarter/bin/j2d /home/barrycarter/SPICE/cspice/lib/cspice.a -lm
/home/barrycarter/bin/gfevnt: gfevnt-example.c
	gcc -I /home/barrycarter/SPICE/cspice/include gfevnt-example.c -o /home/barrycarter/bin/gfevnt /home/barrycarter/SPICE/cspice/lib/cspice.a -lm
/home/barrycarter/bin/gfuds: gfuds-example.c
	gcc -I /home/barrycarter/SPICE/cspice/include gfuds-example.c -o /home/barrycarter/bin/gfuds /home/barrycarter/SPICE/cspice/lib/cspice.a -lm
/home/barrycarter/bin/gfudb: gfudb-example.c
	gcc -I /home/barrycarter/SPICE/cspice/include gfudb-example.c -o /home/barrycarter/bin/gfudb /home/barrycarter/SPICE/cspice/lib/cspice.a -lm
