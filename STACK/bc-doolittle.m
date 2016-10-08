n = a+b+c+d;

s = (a+c)/n;

H = a/(a+c);

F = b/(b+d);

dssAbcd = (a*d-b*c)/Sqrt[((a+b)*(c+d)*(a+c)*(b+d))]

dssHfs = 
 (H*(1-F)-(1-H)*F)*(((H/(1-s) + ((F/s)))*((1-H)/(1-s)+(1-F)/s))^(-1/2))

p1 = h*(1-f)-(1-h)*f

p2 = h/(1-s) + f/s

p3 = (1-h)/(1-s) + (1-f)/s

p4 = p1*(p2*p3)^(-1/2)

conds = {h>0, f>0, s>0, a>0, b>0, c>0, d>0}

p5 = FullSimplify[p4 /. {h -> a/(a+c), s -> (a+c)/n, f -> b/(b+d)},conds]

p6 = FullSimplify[p5 /. {n -> a+b+c+d}, conds]

