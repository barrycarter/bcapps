(* integrating polynomial against Chebyshev [swear Ive done this
somewhere here already?] *)

poly = Sum[p[i]*x^i,{i,0,5}]

Integrate[p*Cos[n*x],{x,-1,1}]

conds = {Element[i,Integers],i>=0, Element[n,Reals], Element[c,Reals]}

Simplify[Integrate[Cos[n*(x-c)]*x^i,{x,-1,1}],conds]



Integrate[Cos[n*(x-c)]*x,{x,-1,1}]

Integrate[Cos[n*(x-c)]*x^2,{x,-1,1}]






