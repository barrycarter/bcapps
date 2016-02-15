atest[n_] := 

Sum[-2*x[i]*(-((Sum[x[i]*y[i], {i, 1, n}]^2*Sum[z[i], {i, 1, n}] - 
      Sum[x[i]^2, {i, 1, n}]*Sum[y[i]^2, {i, 1, n}]*Sum[z[i], {i, 1, n}] - 
      Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}]*
       Sum[x[i]*z[i], {i, 1, n}] + Sum[x[i], {i, 1, n}]*Sum[y[i]^2, {i, 1, n}]*
       Sum[x[i]*z[i], {i, 1, n}] + Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]*
       Sum[y[i]*z[i], {i, 1, n}] - Sum[x[i], {i, 1, n}]*
       Sum[x[i]*y[i], {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}])/
     (Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]^2 - 2*Sum[x[i], {i, 1, n}]*
       Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}] + 
      n*Sum[x[i]*y[i], {i, 1, n}]^2 + Sum[x[i], {i, 1, n}]^2*
       Sum[y[i]^2, {i, 1, n}] - n*Sum[x[i]^2, {i, 1, n}]*
       Sum[y[i]^2, {i, 1, n}])) + 
   ((Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}]*Sum[z[i], {i, 1, n}] - 
      Sum[x[i], {i, 1, n}]*Sum[y[i]^2, {i, 1, n}]*Sum[z[i], {i, 1, n}] - 
      Sum[y[i], {i, 1, n}]^2*Sum[x[i]*z[i], {i, 1, n}] + 
      n*Sum[y[i]^2, {i, 1, n}]*Sum[x[i]*z[i], {i, 1, n}] + 
      Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}] - 
      n*Sum[x[i]*y[i], {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}])*x[i])/
    (Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]^2 - 
     2*Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}] + 
     n*Sum[x[i]*y[i], {i, 1, n}]^2 + Sum[x[i], {i, 1, n}]^2*
      Sum[y[i]^2, {i, 1, n}] - n*Sum[x[i]^2, {i, 1, n}]*
      Sum[y[i]^2, {i, 1, n}]) + 
   ((-(Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[z[i], {i, 1, n}]) + 
      Sum[x[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}]*Sum[z[i], {i, 1, n}] + 
      Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[x[i]*z[i], {i, 1, n}] - 
      n*Sum[x[i]*y[i], {i, 1, n}]*Sum[x[i]*z[i], {i, 1, n}] - 
      Sum[x[i], {i, 1, n}]^2*Sum[y[i]*z[i], {i, 1, n}] + 
      n*Sum[x[i]^2, {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}])*y[i])/
    (Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]^2 - 
     2*Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}] + 
     n*Sum[x[i]*y[i], {i, 1, n}]^2 + Sum[x[i], {i, 1, n}]^2*
      Sum[y[i]^2, {i, 1, n}] - n*Sum[x[i]^2, {i, 1, n}]*
     Sum[y[i]^2, {i, 1, n}]) + z[i]), {i, 1, n}];

btest[n_] :=

Sum[-2*y[i]*(-((Sum[x[i]*y[i], {i, 1, n}]^2*Sum[z[i], {i, 1, n}] - 
      Sum[x[i]^2, {i, 1, n}]*Sum[y[i]^2, {i, 1, n}]*Sum[z[i], {i, 1, n}] - 
      Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}]*
       Sum[x[i]*z[i], {i, 1, n}] + Sum[x[i], {i, 1, n}]*Sum[y[i]^2, {i, 1, n}]*
       Sum[x[i]*z[i], {i, 1, n}] + Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]*
       Sum[y[i]*z[i], {i, 1, n}] - Sum[x[i], {i, 1, n}]*
       Sum[x[i]*y[i], {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}])/
     (Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]^2 - 2*Sum[x[i], {i, 1, n}]*
       Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}] + 
      n*Sum[x[i]*y[i], {i, 1, n}]^2 + Sum[x[i], {i, 1, n}]^2*
       Sum[y[i]^2, {i, 1, n}] - n*Sum[x[i]^2, {i, 1, n}]*
       Sum[y[i]^2, {i, 1, n}])) + 
   ((Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}]*Sum[z[i], {i, 1, n}] - 
      Sum[x[i], {i, 1, n}]*Sum[y[i]^2, {i, 1, n}]*Sum[z[i], {i, 1, n}] - 
      Sum[y[i], {i, 1, n}]^2*Sum[x[i]*z[i], {i, 1, n}] + 
      n*Sum[y[i]^2, {i, 1, n}]*Sum[x[i]*z[i], {i, 1, n}] + 
      Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}] - 
      n*Sum[x[i]*y[i], {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}])*x[i])/
    (Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]^2 - 
     2*Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}] + 
     n*Sum[x[i]*y[i], {i, 1, n}]^2 + Sum[x[i], {i, 1, n}]^2*
      Sum[y[i]^2, {i, 1, n}] - n*Sum[x[i]^2, {i, 1, n}]*
      Sum[y[i]^2, {i, 1, n}]) + 
   ((-(Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[z[i], {i, 1, n}]) + 
      Sum[x[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}]*Sum[z[i], {i, 1, n}] + 
      Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[x[i]*z[i], {i, 1, n}] - 
      n*Sum[x[i]*y[i], {i, 1, n}]*Sum[x[i]*z[i], {i, 1, n}] - 
      Sum[x[i], {i, 1, n}]^2*Sum[y[i]*z[i], {i, 1, n}] + 
      n*Sum[x[i]^2, {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}])*y[i])/
    (Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]^2 - 
     2*Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}] + 
     n*Sum[x[i]*y[i], {i, 1, n}]^2 + Sum[x[i], {i, 1, n}]^2*
      Sum[y[i]^2, {i, 1, n}] - n*Sum[x[i]^2, {i, 1, n}]*
      Sum[y[i]^2, {i, 1, n}]) + z[i]), {i, 1, n}];

ctest[n_] :=

Sum[-2*(-((Sum[x[i]*y[i], {i, 1, n}]^2*Sum[z[i], {i, 1, n}] - 
      Sum[x[i]^2, {i, 1, n}]*Sum[y[i]^2, {i, 1, n}]*Sum[z[i], {i, 1, n}] - 
      Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}]*
       Sum[x[i]*z[i], {i, 1, n}] + Sum[x[i], {i, 1, n}]*Sum[y[i]^2, {i, 1, n}]*
       Sum[x[i]*z[i], {i, 1, n}] + Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]*
       Sum[y[i]*z[i], {i, 1, n}] - Sum[x[i], {i, 1, n}]*
       Sum[x[i]*y[i], {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}])/
     (Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]^2 - 2*Sum[x[i], {i, 1, n}]*
       Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}] + 
      n*Sum[x[i]*y[i], {i, 1, n}]^2 + Sum[x[i], {i, 1, n}]^2*
       Sum[y[i]^2, {i, 1, n}] - n*Sum[x[i]^2, {i, 1, n}]*
       Sum[y[i]^2, {i, 1, n}])) + 
   ((Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}]*Sum[z[i], {i, 1, n}] - 
      Sum[x[i], {i, 1, n}]*Sum[y[i]^2, {i, 1, n}]*Sum[z[i], {i, 1, n}] - 
      Sum[y[i], {i, 1, n}]^2*Sum[x[i]*z[i], {i, 1, n}] + 
      n*Sum[y[i]^2, {i, 1, n}]*Sum[x[i]*z[i], {i, 1, n}] + 
      Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}] - 
      n*Sum[x[i]*y[i], {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}])*x[i])/
    (Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]^2 - 
     2*Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}] + 
     n*Sum[x[i]*y[i], {i, 1, n}]^2 + Sum[x[i], {i, 1, n}]^2*
      Sum[y[i]^2, {i, 1, n}] - n*Sum[x[i]^2, {i, 1, n}]*
      Sum[y[i]^2, {i, 1, n}]) + 
   ((-(Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[z[i], {i, 1, n}]) + 
      Sum[x[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}]*Sum[z[i], {i, 1, n}] + 
      Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[x[i]*z[i], {i, 1, n}] - 
      n*Sum[x[i]*y[i], {i, 1, n}]*Sum[x[i]*z[i], {i, 1, n}] - 
      Sum[x[i], {i, 1, n}]^2*Sum[y[i]*z[i], {i, 1, n}] + 
      n*Sum[x[i]^2, {i, 1, n}]*Sum[y[i]*z[i], {i, 1, n}])*y[i])/
    (Sum[x[i]^2, {i, 1, n}]*Sum[y[i], {i, 1, n}]^2 - 
     2*Sum[x[i], {i, 1, n}]*Sum[y[i], {i, 1, n}]*Sum[x[i]*y[i], {i, 1, n}] + 
     n*Sum[x[i]*y[i], {i, 1, n}]^2 + Sum[x[i], {i, 1, n}]^2*
      Sum[y[i]^2, {i, 1, n}] - n*Sum[x[i]^2, {i, 1, n}]*
      Sum[y[i]^2, {i, 1, n}]) + z[i]), {i, 1, n}];
