Print[2+2];

f[x_] = x^2;

Print[f[x]];

raDecLatLonGMST2azAlt[ra_, dec_, lat_, lon_, gmst_] = 
 {ArcTan[Cos[lat]*Sin[dec] - Cos[dec]*Cos[gmst + lon - ra]*Sin[lat], 
  -(Cos[dec]*Sin[gmst + lon - ra])], 
 ArcTan[Sqrt[(Cos[lat]*Sin[dec] - Cos[dec]*Cos[gmst + lon - ra]*Sin[lat])^2 + 
    Cos[dec]^2*Sin[gmst + lon - ra]^2], 
  Cos[dec]*Cos[lat]*Cos[gmst + lon - ra] + Sin[dec]*Sin[lat]]};


Print[raDecLatLonGMST2azAlt[a, b, c, d, e]]


