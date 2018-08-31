(*

Better answer to
https://earthscience.stackexchange.com/questions/14132/how-much-of-earths-land-area-has-antipodal-land-area
using coastal data?

*)

coast0 = ReadList[
 "!bzcat /home/barrycarter/20180807/dist2coast.signed.txt.bz2", {Number,
Number, Number}];

coast = Partition[coast0, 9000];

(* trying to find position directly based on symmetry *)

t1517 = coast0[[;;;;100]];



(* the antipode, determined in a way thats consistent with coast0 [ie,
longitude between -180 and 180 and latitude between -90 and 90] *)

antipode[lon_, lat_] = {If[lon<0, lon+180, lon-180], -lat};

t1511 = Map[#[[;;;;10]] &, coast, {1}][[;;;;10]];



