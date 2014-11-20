(* elliptical orbit given parameters *)

(* area traced out from focus given CENTRAL angle *)

focarea[a_,b_,th_] = (a*b*((2*a*b)/(a^2 + b^2 + (-a^2 + b^2)*Cos[2*th]) - 
   (Sqrt[(a - b)*(a + b)]*Sin[th])/Sqrt[b^2*Cos[th]^2 + a^2*Sin[th]^2]))/2

(* eccentricity given semimajor and semiminor axes *)

ecc[a_,b_] = 1-Sqrt[b*b/a/a]

(* semimajor given semiminor and ecc, it's a*(1-e) *)

Solve[ecc[a,b] == e, b]

(* for mercury below, AU *)

a = 3.870974477755457*10^-1
e = 2.056375198181663*10^-1

(* thus b... *)

b = a*(1-e)

(* mean anamoly at given time 2014-May-20 00:00:00.0000 *)

ma = 6.978017675467898*10

(* area swept out *)

Solve[focarea[a,b,th] == ma/360*Pi*a*b, th]

focarea[a,b,ma*Degree]




