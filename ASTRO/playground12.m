(* http://astronomy.stackexchange.com/questions/10701/finding-latitude-and-longitude-of-a-person-or-of-where-a-picture-was-taken *)

(*

Imagine you are at 35N,106W at 5h local sidereal time.

The celestial north pole is at (0,90) in the celestial frame and
(0,35) in your frame.

The point (5h,0) is (75,0) in the celestial sphere (1h = 15 degrees),
and (180,55) in your frame

The point (11h,0) is (165,0) in the celestial sphere and (90,0)
(setting in the east) in your frame.

Converting to rectangular coordinates, we need the matrix that does this:

{0,0,1} -> {Cos[35 Degree], 0, Sin[35 Degree]}

{Cos[75*Degree],Sin[75*Degree],0} -> {-Sin[35 Degree], 0, Cos[35 Degree]}

{Sin[-75*Degree],Cos[75*Degree],0} -> {0,1,0}

or, generalizing a bit (lst = local sidereal time as an angle, lat =
latitude, notice that lon is irrelevant since we're using local
sidereal time)

{0,0,1} -> {Cos[lat], 0, Sin[lat]}

{Cos[lst],Sin[lst],0} -> {-Sin[lat], 0, Cos[lat]}

{-Sin[lst],Cos[lst],0} -> {0,1,0}

Solving (Mathematica):

*)

m0 = Table[a[i,j],{i,1,3},{j,1,3}]

(* this is technically an incorrect use of Simplify, but it works *)

m = Simplify[m0 /. Solve[{
 m.{0,0,1} == {Cos[lat], 0, Sin[lat]},
 m.{Cos[lst],Sin[lst],0} == {-Sin[lat], 0, Cos[lat]},
 m.{-Sin[lst],Cos[lst],0} == {0,1,0}
},Flatten[m]],Reals]

m = m[[1]]

(*

This gives us

$
   \left(
   \begin{array}{ccc}
    -\cos (\text{lst}) \sin (\text{lat}) & -\sin (\text{lat}) \sin (\text{lst})
      & \cos (\text{lat}) \\
    -\sin (\text{lst}) & \cos (\text{lst}) & 0 \\
    \cos (\text{lat}) \cos (\text{lst}) & \cos (\text{lat}) \sin (\text{lst}) &
      \sin (\text{lat}) \\
   \end{array}
   \right)
$

The inverse of this matrix:

$
   \left(
   \begin{array}{ccc}
    -\cos (\text{lst}) \sin (\text{lat}) & -\sin (\text{lst}) & \cos
      (\text{lat}) \cos (\text{lst}) \\
    -\sin (\text{lat}) \sin (\text{lst}) & \cos (\text{lst}) & \cos (\text{lat})
      \sin (\text{lst}) \\
    \cos (\text{lat}) & 0 & \sin (\text{lat}) \\
   \end{array}
   \right)
$

will transform rectangular azimuth and elevation back to right
ascension and declination and right ascension. This would be an
interesting alternative approach to this problem, but I won't be using
it.

OK, if we convert right ascension and declination to rectangular
coordinates, multiply by the first matrix above and convert the result
back to spherical coordinates, we will have azimuth and
elevation. Let's do that...

The spherical coordinates for (ra,dec) are:

{Cos[dec] Cos[ra], Cos[dec] Sin[ra], Sin[dec]}

Multiplying by the matrix, we get

$
   \{\sin (\text{dec}) \cos (\text{lat})-\cos (\text{dec}) \sin (\text{lat})
    \cos (\text{lst}-\text{ra}),-\cos (\text{dec}) \sin
    (\text{lst}-\text{ra}),\cos (\text{dec}) \cos (\text{lat}) \cos
    (\text{lst}-\text{ra})+\sin (\text{dec}) \sin (\text{lat})\}
$

(note that lst-ra is sometimes called the "hour angle", which would
simplify the above)

Converting back to spherical coordinates and simplifying:

*)

{x,y,z} = Simplify[m.{Cos[dec] Cos[ra], Cos[dec] Sin[ra], Sin[dec]},Reals]

az = ArcTan[y,x]
el = ArcTan[z,Sqrt[x^2+y^2]]


