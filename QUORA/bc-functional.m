Clear[f];

f[x_] := f[x] = f[x-1]^2 - (x-1)

f[0] = c;

Table[f[i],{i,1,20}]

Solve[
