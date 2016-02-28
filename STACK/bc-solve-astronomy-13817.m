(*

a = 10/300/10^6
conds = {t>0, a>0, v>0, v<1}
factor[v_] = (1-v^2)^(-1/2)
speed[t_] = Tanh[a*t]
distance[t_] = Integrate[speed[t],t]
rate[t_] = FullSimplify[1/factor[speed[t]], conds]
elapsed[t_] = FullSimplify[Integrate[rate[t],t],conds]
distrat[t_] = FullSimplify[1/factor[speed[t]],conds]
totdist[t_] = 

FullSimplify[Integrate[speed[t]*distrat[t],t],conds]




TODO: it would be more fun to derive these from first principles

This doesn't fully answer your question.

As you accelerate away from star 1 at 10m/s^2, Newtonian mechanics
would give your velocity at time t as 10*t.

travels distance u in 1 second

your distance u = u/factor[v], factor[v], or u + v - uv^2

accel = 10/300/10^6

Solve[Tanh[accel*t] == .6, t]

I say: .5 light seconds in 1 second

converted: 0.433013 light seconds in 1.1547s or 


factor[v_] = (1-v^2)^(-1/2)

Plot[1-v^2,{v,0,1}]

DSolve[{v'[t] == u*(1-v[t]^2),v[0]==0},v[t],t]

u = 10/300000000

Plot[Tanh[t*u]*300000000,{t,0,30000000},PlotRange->All]

f[u_] = u + u*(1-u^2)

RSolve[{
 a[n+1] == a[n] + a[n]*(1-a[n]^2),
 a[0] == 2
},
a[n],n]

