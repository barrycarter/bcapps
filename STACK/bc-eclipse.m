(* fun with 2017 Aug solar eclipse *)

(*

Aug 21, 2017 at 15:46 UTC = eclipse start = 1503330360

so lets HORIZONS and look at 18:46 UTC

ascp1950.430.bz2.sun,earthmoon,moongeo.mx


(* TODO: RESTORE factor TO ONE WHEN FINAL *)

factor = 1000;

earth = {8.663956678832780*10^-01, -5.207951371991623*10^-01,
 -1.188740575217250*10^-04}/factor;

sun = {2.504271325669393*10^-03, 5.413709545349687*10^-03,
-1.366868862270140*10^-04}/factor;

moon = {8.642682707645408*10^-01, -5.195058046203309*10^-01,
-9.967783505380239*10^-05}/factor;

au = 149597870700;

mrad = 1737.4/au

erad = 6371.01/au

srad = 6.963*10^5/au

obj = {
 RGBColor[1,1,0],
 Ball[sun, srad],
 RGBColor[0,0,1],
 Ball[earth, erad],
 RGBColor[1,1,1],
 Ball[moon, mrad]
};

Graphics3D[obj]
Show[%, ViewPoint -> earth, ViewVector -> earth-sun, ImageSize -> {1024,768},
 ViewCenter -> Sun, SphericalRegion -> True, Lighting -> None]
showit



TODO: test vs horizons
