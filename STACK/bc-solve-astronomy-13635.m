er = 6371;

major = 9600;
minor = ellipseEA2B[major,.2]

s[t_] = {major*Cos[t], minor*Sin[t]};

g2 = ParametricPlot[s[t],{t,0,2*Pi}]

g1 = Graphics[{
 RGBColor[{0,0,1}],
 Disk[{0,0}, er],







}
];

Show[g1,g2]
