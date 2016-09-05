https://www.quora.com/How-do-we-find-a-closed-form-for-tan-2-pi-7

Im[Expand[(ExpToTrig[Exp[I*2*Pi/7]])^7]] /. {Cos[3*Pi/14] -> x, 
 Sin[3*Pi/14]^2 -> 1-x^2, Sin[3*Pi/14]^4 -> (1-x^2)^2, 
 Sin[3*Pi/14]^6 -> (1-x^2)^3}

Expand[Im[Expand[(ExpToTrig[Exp[I*2*Pi/7]])^7]] /. {Cos[3*Pi/14] -> x, 
 Sin[3*Pi/14]^2 -> 1-x^2, Sin[3*Pi/14]^4 -> (1-x^2)^2, 
 Sin[3*Pi/14]^6 -> (1-x^2)^3}]


