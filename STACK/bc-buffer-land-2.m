(*

different and easier approach to solve 

https://earthscience.stackexchange.com/questions/14656/how-to-calculate-boundary-around-all-land-on-earth

using https://oceancolor.gsfc.nasa.gov/docs/distfromcoast/ (signed version)

*)

(* head just for testing:

bzcat /home/barrycarter/20180807/dist2coast.signed.txt.bz2 | head -n 500 >
 /tmp/test.m

*)

ReadList["/tmp/test.m", {Number, Number, Number}];


