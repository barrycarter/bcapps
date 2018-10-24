(* cleaned up and well-commented version for SE *)

(*

I assume that Mercury's orbit is planar, and that Venus' orbit lies in
the same plane, or at least intersects it at the appropriate time.

This allows me to use a two-dimensional equation for acceleration due
to gravity, instead of a 3 dimensional one.

The equation (below) is the acceleration imparted to an object of mass
m1 at {x1,y1} by an object of mass m2 at {x2,y2}, given that the
gravitational constant is g.

Note that the mass of the object being accelerated (m1) is actually
irrelevant; however, I include it as a parameter for symmetry

*)

accel[{x1_,y1_},{x2_,y2_},m1_,m2_,g_]=g*m2/Norm[{x2-x1,y2-y1}]^3*{x2-x1,y2-y1}

(* 

The mass, semimajor axis, period, and radius of Mercury, in kg, m (not
km), and s

*)

mercsma = 57909050000;
mercper = 87.9691*86400
mercrad = 2439700
mercmass = 3.3011*10^23

(* solar mass, in kg *)

sunmass = 1.98855*10^30

(* gravitational constant of universe, in kg-m-s system *)

g = 6.6740*10^-11

(* 

Heliocentric, so Sun is always at origin. In theory, the positions of
the other planets (eg, Jupiter) could help boost your payload, so you
might be able to launch with a lower speed than I find below

*)

sun[t_] = {0,0}

(*

I assume Mercury's orbit is circular. Since the actual orbit is
elliptical, you could get a boost for your payload by launching it
when Mercury's distance from the Sun is increasing the fastest (in
other words, solar radial velocity is greatest)

I've chosen the x axis to be the line connecting the Sun to Mercury at time 0.

*)

merc[t_] = {Cos[t*2*Pi/mercper],Sin[t*2*Pi/mercper]}*mercsma

(*

I also ignore Venus' own gravity: you can do slightly better by noting
that Venus will pull the payload towards itself once the payload gets
close enough.

I do want to plot Venus' orbit, so I use the semi-major axis and
period values below.

Venus' starting angle (vsa below) was found by trial and error to make
sure Venus was at the right place when the payload crossed its orbit.

*)

vensma = 108208000000
venper = 224.701*86400;
vsa = 53*Degree;
ven[t_] = {Cos[t*2*Pi/venper+vsa],Sin[t*2*Pi/venper+vsa]}*vensma

(*

If we launch from side of Mercury furthest from the Sun, the payload's
starting position will be Mercury's position plus Mercury's radius in
the x direction

NOTE: This start position is completely arbitrary; you may get better
results by starting at different positions on Mercury's surface.

*)

s0 = {mercsma+mercrad,0}

(*

The initial velocity of the payload (with respect to the Sun) will be
Mercury's velocity + whatever velocity (delta v) we impart to the
payload.

Note that both the direction I choose for initial velocity (in the
same direction as Mercury's orbit) and the magnitude are
arbitrary. You may get better results by aiming the payload at a 45
degree angle or straight up or something.

NOTE: If I change 13000 to 12500 below, Mathematica will refuse to
solve the differential equation. This doesn't necessarily mean 13000
is a minimal velocity, but there is apparently some sort of important
change between 12500 m/s and 13000 m/s

*)

v0 = merc'[0] + {0,12800}

(*

Mathematica won't close-form integrate this problem, so we integrate
numerically, which requires a start time (0) and an end time (below).

I chose 35 days after confirming that's how long it takes the payload
to reach Venus.

*)

timelimit = 86400*35;

nds = NDSolve[{s[0]==s0, s'[0] == v0,
 s''[t] == accel[s[t],sun[t],1,sunmass,g] + accel[s[t],merc[t],1,mercmass,g]
},s,{t,0,timelimit}]

(* The use of [[1,1,2]] below is just Mathematica nesting weirdness *)

graph= ParametricPlot[{nds[[1,1,2]][t],merc[t],ven[t]},{t,0,timelimit}, 
 Mesh -> timelimit/86400, AxesOrigin->{0,0}, PlotStyle -> {Blue,Red,Green},
 MeshStyle -> {Black}
]

(* checking other answer *)

(*
nds = NDSolve[{s[0]==s0, s'[0] == merc'[0]+{0,8000},
 s''[t] == accel[s[t],sun[t],1,sunmass,g] + accel[s[t],merc[t],1,mercmass,g]
},s,{t,0,timelimit}]

graph= ParametricPlot[{nds[[1,1,2]][t],merc[t],ven[t]},{t,0,221}, 
 Mesh -> timelimit/86400, AxesOrigin->{0,0}, PlotStyle -> {Blue,Red,Green},
 MeshStyle -> {Black}
]

*)
