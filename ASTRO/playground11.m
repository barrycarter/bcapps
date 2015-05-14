(*

Closed form formulas for some astronomical quantities.

The goal here is to find complicated-looking but easy-to-compute
formulas for people who want to "plug and chug"

I build up the formulas naturally, but give the end result as a
formula, not as a composition of formulas

All times in Unix seconds

All angles (including right ascension and declination and siderial
time) in radians

I will use precise numbers to avoid losing precision, but the
precision is generally unwarranted

These formulas strive for decent accuracy 1901-2099

*)

(*

In each case, I'll show the intermediate steps but enclose them as comments.

http://aa.usno.navy.mil/faq/docs/GAST.php

see also: http://aa.usno.navy.mil/publications/docs/Circular_163.pdf

gmst0[d_] = Rationalize[18.697374558+24.06570982441908*d,10^-100]

Convert Unix seconds to above (946728000 = Unix time at 2000-01-01 12h UT)

temp0[s_] = (s-946728000)/86400

and convert to radians

gmst[s_] = Expand[gmst0[temp0[s]]/12*Pi]

yielding...:

*)

gmst[s_] = (-452506800334363673497*Pi)/20593349747540136 + (424749743*Pi*s)/18299087654400

(*

e0[d_] = Rationalize[23.4393 - 0.0000004*d,10^-100]*Degree

l0[d_] = Rationalize[280.47 + 0.98565*d,10^-100]*Degree

omega0[d_] = Rationalize[125.04 - 0.052954*d,10^-100]*Degree

deltapsi0[d_]= Rationalize[
 -0.000319*Sin[omega0[d]]-0.000024*Sin[2*l0[d]],10^-100]

eqeq0[d_] = Rationalize[deltapsi0[d]*Cos[e0[d]],10^-100] /. Degree -> Pi/180

converting d to seconds and final answer to radians

gmst[s] + eqeq0[temp0[s]]/12*Pi

TODO: need to test formula below

TODO: some of above values are interesting in and of themselves

*)

gast[s_] = (-452506800334363673497*Pi)/20593349747540136 + 
 (424749743*Pi*s)/18299087654400 - 
 (319*Pi*Sin[(Pi*(30468245256000 - 26477*s))/7776000000000]*
   Sin[(Pi*(14376164472000 + s))/38880000000000])/12000000 + 
 (Pi*Sin[(Pi*(14376164472000 + s))/38880000000000]*
   Sin[(Pi*(5881032000 + 6571*s))/51840000000])/500000

obliquity[s_] = -(Pi*(-5063835528000 + s))/38880000000000


