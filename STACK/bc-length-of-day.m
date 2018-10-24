(* http://earthscience.stackexchange.com/questions/9083/latitude-and-daylight-hours *)

Using the formulas I derive at http://astronomy.stackexchange.com/questions/14492/need-simple-equation-for-rise-transit-and-set-time we see that an object at declination $\delta$ rises at $\alpha -\cos ^{-1}(-\tan (\delta ) \tan (\lambda ))$ and sets at $\alpha +\cos ^{-1}(-\tan (\delta ) \tan (\lambda ))$ where $\alpha$ is the right ascension, $\delta$ is the declination, and $\lambda$ is the observer's latitude.

Subtracting these, the right ascension cancels out for a total uptime (from rise to set) of $2 \cos ^{-1}(-\tan (\delta ) \tan (\lambda ))$

https://en.wikipedia.org/wiki/Position_of_the_Sun#Calculations gives us the declination of the Sun as $(-23.44 {}^{\circ}) \cos \left(\frac{1}{365} (N+10) (360 {}^{\circ})\right)$

Combining the two formulas, we see that, on the Nth day of the year, at latitude $\lambda$, the Sun is up

$
   2 \cos ^{-1}\left(-\tan (\lambda ) \tan \left((-23.44 {}^{\circ}) \cos
    \left(\frac{1}{365} (N+10) (360 {}^{\circ})\right)\right)\right)
$

The time units above are such that $2 \pi$ is one day (24 hours). To convert to hours, we multiply by $\frac{24}{2 \pi }$ to get:

$
   2 \frac{24}{2 \pi } \cos ^{-1}\left(-\tan (\lambda ) \tan \left((-23.44
    {}^{\circ}) \cos \left(\frac{1}{365} (N+10) (360
    {}^{\circ})\right)\right)\right)
$

This formula can be simplified slightly, but we can now plot the
approximate length of day for various latitudes:

lod[lat_, N_] = 2*ArcCos[-Tan[-23.44*Degree*Cos[360*Degree/365*(N+10)]]*
 Tan[lat]]*24/(2*Pi)



Plot[{
 lod[0*Degree,t],
 lod[15*Degree,t],
 lod[30*Degree,t],
 lod[45*Degree,t],
 lod[60*Degree,t],
 lod[75*Degree,t],
 lod[(90-10^-10)*Degree,t]
}, {t,1,365}, AxesOrigin -> {0,0}, PlotLegends -> 
 {HoldForm[0*Degree], 15*Degree, 30*Degree, 45*Degree, 60*Degree,
 75*Degree, 90*Degree}, 
PlotLabel -> "Length of Day (hours)", PlotRange -> All
]
showit

Plot[{
 lod[30*Degree,t],
 lod[45*Degree,t],
 lod[60*Degree,t],
 lod[75*Degree,t]
}, {t,1,365}, AxesOrigin -> {0,0}, 
PlotLegends ->  {30*Degree, 45*Degree, 60*Degree, 75*Degree}, 
PlotLabel -> "Length of Day (hours)", PlotRange -> All, 
 AxesLabel -> {"Day of Year", ""}
]
showit

Plot[{
 lod[0*Degree,t],
 lod[15*Degree,t],
 lod[30*Degree,t],
 lod[45*Degree,t],
 lod[60*Degree,t],
 lod[75*Degree,t],
 lod[89.99999999*Degree,t]
}, {t,1,365}]


%% TODO: note this file

dec[N_] = -23.44*Degree*Cos[360*Degree/365*(N+10)]

uptime[lat_,dec_] = 2*ArcCos[-Tan[dec]*Tan[lat]]

HoldForm[-23.44*Degree]*Cos[HoldForm[360*Degree]/365*(N+10)]


2*ArcCos[-Tan[HoldForm[-23.44*Degree]*Cos[HoldForm[360*Degree]/365*(N+10)]]*
 Tan[lambda]]*HoldForm[24/(2*Pi)]

2*ArcCos[-Tan[-23.44*Degree*Cos[360*Degree/365*(N+10)]]*Tan[lambda]]*24/(2*Pi)








CHANGES DURING DAY, REFRACTION, ETC









TODO: homework but
