(x+1)^n - x^n

Sum[Binomial[n,m]*x^m,{m,0,n}]


f[n_] = Sum[Binomial[n,m]*x^m,{m,0,n-1}]

f[n_] = Sum[Binomial[n,m]*x^m,{m,0,n-2}]

f[n+1]-f[n]

f[0,x_] = x^7

f[n_,x_] := f[n] = f[n-1,x] - f[n-1,x-1]

powers = Table[i^7,{i,1,100}];

the numbers are:

{1, 127, 1932, 10206, 25200, 31920, 20160, 5040, 0}

f[0,x_,n_] = x^n

f[m_,x_,n_] := f[m,x,n] = f[m-1,x+1,n] - f[m-1,x,n]

RSolve[{
 g[0,x,n] == x^n,
 g[m,x,n] == g[m-1,x+1,n] - g[m-1,x,n]
}, g, {m,x,n}]

(x+1)^(n+1) - x^(n+1)

a0+d*n

Sum[a0+d*k, {k,0,n}]






