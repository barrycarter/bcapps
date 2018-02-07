(* based on bc-astro-formulas.m *)


TODO: special cases tropics, arctic; mention bc-astro-formulas

If your latitude "lat" is between 0.423637 and 1.14716 radians (that's 24.2726 and 65.7274 degrees) north or south of the equator, your "minimum" and "maximum" solar azimuths are:

$
\pi -\cos ^{-1}(0.0145454 \tan (\left| \text{lat}\right| )+0.397819 \sec
(\text{lat}))
$

radians on either side of where the Sun culminates. For the northern hemisphere, the sun culminates in the south; for the southern hemisphere, in the north. Examples:

  - Melbourne, Australia has a latitude of 37.8136 degrees south of the equator, or 0.659972 radians. Plugging in 0.659972 for lat (or -0.659972, which will yield the same result) above yields 2.11163 radians or 120.987 degrees. Since the sun culminates in the north (azimuth zero degrees), this means that, on the southern hemisphere's summer solstice (which occurs in December, not June), the Melbourne sun will rise 120.987 degrees east of north, and set 120.987 degrees west of north (which is an azimuth of 360-120.987 or 239.013 degrees), traversing a total of 241.975 degrees.

I'll explain more why this formula is correct shortly, but you can visit https://www.timeanddate.com/sun/australia/melbourne?month=12&year=2018 and scroll down to the 22nd or so (this year's solstice time in Melbourne) to confirm these numbers are at least approximately right.

  - Key West, Florida, USA has a latitude of 24.5551 degrees north of the equator (only a little north of our latitude limit above), 

37.8136


not really minmax

TODO: fix zenith condition, no refraction there


caveats!!!!

decLatAlt2az[e, lat, 5/6*Pi/180]

fixed ecliptic all day

south/north
