(* position of North Pole in J2000 frame, allowing for precession *)

(* This shell command obtains list:

bzfgrep 'E+' north-pole-from-geocenter.txt.bz2 | perl -anle 'map(s/E/*10^/g, @F); print "{",join(", ",@F),"},"; sub BEGIN {print "list={";}; sub END {print "{}}; list = Drop[list,-1]"}' > /tmp/math.m

*)

