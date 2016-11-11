(*

https://www.reddit.com/r/cheatatmathhomework/comments/5caytt/among_all_triangles_inscribed_in_a_circle_of/

 *)


conds = Element[{x,y,z}, Reals]

p[x_] = {Cos[x], Sin[x]}
a = FullSimplify[Norm[p[x]-p[y]],conds]
b = FullSimplify[Norm[p[x]-p[z]],conds]
c = FullSimplify[Norm[p[z]-p[y]],conds]
s = FullSimplify[(a+b+c)/2,conds]

FullSimplify[s*(s-a)*(s-b)*(s-c),conds]

FullSimplify[Sqrt[s*(s-a)*(s-b)*(s-c)],conds]

OR...


a = {Cos[x], Sin[x]}
b = {-Cos[x], Sin[x]}

c = {Cos[y], Sin[y]}

2*Cos[x]*(Sin[y]-Sin[x])




