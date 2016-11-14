(* uses moonstuff.m to find perigee-syzygys, ie supermoons *)

p[n_] = Fit[perigees, {1,n}, n];

diffsper = Table[perigees[[i]]-p[i],{i,1,Length[perigees]}]

f[n_] = Fit[full, {1,n}, n];

diffsful = Table[full[[i]]-f[i],{i,1,Length[full]}]

1325 perigees, 1237 fulls

test = Table[{i*1325/1237, full[[i]]},{i,1,Length[full]}]

ListPlot[{test, perigees}]

ListPlot[Take[Abs[Fourier[diffsful]],20], PlotRange -> All]

365.2425/29.530591083448364 = 12.3683

f[n_] = Fit[full, {1,n}, n];

f2[n_] = a + b*n + c*Sin[d*n - e] /. 
 FindFit[full, a + b*n , {a,b,{c,0.6},{d,6/Pi},e}, n]

diffsful2 = Table[full[[i]]-f2[i],{i,1,Length[full]}]



