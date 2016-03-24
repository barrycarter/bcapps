(*

http://space.stackexchange.com/questions/14537/how-will-a-suborbital-flight-country-to-country-work


TODO: when TeXing up, consider replacing lat/lon 
lat = Subscript[s,"lat"]
lon = Subscript[s,"lon"]

On a rotating spherical Earth with radius $r$, the Cartesian
coordinates of a location with latitude $s_{\text{lat}}$ and longitude
$s_{\text{lon}}$ a time $t$ are:

s[t_,lat_,lon_] = {r*Cos[lat]*Cos[(t-lon)/2/Pi], r*Cos[lat]*Sin[(t-lon)/2/Pi], 
 r*Sin[lat]}







TODO: disclaimers, non elliptical, 0 elevation, not an answer, will crash, no air ressit (prob important because khan? line mentioned)

*)

g = Graphics3D[{
 Lighting -> {{"Directional", Blue, {0,-1,0}}},
 RGBColor[{1,1,1}],
 Sphere[{0,0,0},1],
 RGBColor[{1,0,0}],
 PointSize -> 0.1,
 Point[{0,1,0}],
}];

Show[g, Boxed -> False]
showit

r = Sqrt[x[t]^2+y[t]^2+z[t]^2];

DSolve[{
 x''[t] == -g*((r^2*x[t])/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2)),
 y''[t] == -g*((r^2*y[t])/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2)),
 z''[t] == -g*((r^2*z[t])/(x[t]^2 + y[t]^2 + z[t]^2)^(3/2))
}, {x[t],y[t],z[t]}, t]

