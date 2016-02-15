diff[i_] = (z[i]-(a*x[i]+b*y[i]+c))^2
sum = Sum[diff[i],{i,1,n}]

Solve[{D[sum,a] == 0, D[sum,b] == 0, D[sum,c] ==0},{a,b,c}]

test = Solve[{D[sum,a] == 0, D[sum,b] == 0, D[sum,c] ==0},{a,b,c}] /. n->5

a0 = a /. test;
b0 = b /. test;
c0 = c /. test;

Simplify[a0 /. {x[5] -> xs-(x[1]+x[2]+x[3]+x[4]),
       y[5] -> ys-(y[1]+y[2]+y[3]+y[4])
}]

simps = {
 Sum[x[i],{i,1,5}] -> xs,
 Sum[y[i],{i,1,5}] -> ys,
 Sum[z[i],{i,1,5}] -> zs,
 Sum[x[i]^2,{i,1,5}] -> xss,
 Sum[y[i]^2,{i,1,5}] -> yys,
 Sum[z[i]^2,{i,1,5}] -> zzs,
 Sum[x[i]*y[i],{i,1,5}] -> xys,
 Sum[x[i]*z[i],{i,1,5}] -> xzs,
 Sum[y[i]*z[i],{i,1,5}] -> yzs
}

FullSimplify[a0 /. simps] /. simps








