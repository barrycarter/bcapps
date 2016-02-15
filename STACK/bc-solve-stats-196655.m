diff[i_] = (z[i]-(a*x[i]+b*y[i]+c))^2

agen = 
{-((-(xzs*ys^2) + n*xzs*yys - n*xys*yzs + xs*ys*yzs + xys*ys*zs - xs*yys*zs)/
   (n*xys^2 - 2*xs*xys*ys + xss*ys^2 + xs^2*yys - n*xss*yys))}[[1]]

bgen = 
{-((-n*xys*xzs + xs*xzs*ys - xs^2*yzs + n*xss*yzs + xs*xys*zs - xss*ys*zs)/
   (n*xys^2 - 2*xs*xys*ys + xss*ys^2 + xs^2*yys - n*xss*yys))}[[1]]

cgen = 
{(-(xys*xzs*ys) + xs*xzs*yys - xs*xys*yzs + xss*ys*yzs + xys^2*zs - 
xss*yys*zs)/(n*xys^2 - 2*xs*xys*ys + xss*ys^2 + xs^2*yys - n*xss*yys)}[[1]]





n0 = 5;
sum = Sum[diff[i],{i,1,n0}]
sol = Solve[{D[sum,a] == 0, D[sum,b] == 0, D[sum,c] ==0},{a,b,c}]
a0 = a /. sol;
b0 = b /. sol;
c0 = c /. sol;

simps = {
 Sum[x[i],{i,1,n0}] -> xs,
 Sum[y[i],{i,1,n0}] -> ys,
 Sum[z[i],{i,1,n0}] -> zs,
 Sum[x[i]^2,{i,1,n0}] -> xss,
 Sum[y[i]^2,{i,1,n0}] -> yys,
 Sum[z[i]^2,{i,1,n0}] -> zzs,
 Sum[x[i]*y[i],{i,1,n0}] -> xys,
 Sum[x[i]*z[i],{i,1,n0}] -> xzs,
 Sum[y[i]*z[i],{i,1,n0}] -> yzs
}

FullSimplify[a0 /. simps] /. simps

(*

solutions for various n0

n0 = 4

{-(((-4*ys^2 + 16*yys)*(-16*xzs + 4*xs*zs) - (16*xys - 4*xs*ys)*
     (-16*yzs + 4*ys*zs))/(-(-16*xys + 4*xs*ys)^2 + 
    (-4*xs^2 + 16*xss)*(-4*ys^2 + 16*yys)))}

n0 = 5

a:

{-((-((-4*ys^2 + 20*yys)*(-20*xzs + 4*xs*zs)) + (20*xys - 4*xs*ys)*
     (-20*yzs + 4*ys*zs))/((-20*xys + 4*xs*ys)^2 - 
    (-4*xs^2 + 20*xss)*(-4*ys^2 + 20*yys)))}

{-((-(xzs*ys^2) + 5*xzs*yys - 5*xys*yzs + xs*ys*yzs + xys*ys*zs - xs*yys*zs)/
   (5*xys^2 - 2*xs*xys*ys + xss*ys^2 + xs^2*yys - 5*xss*yys))}


b:

{(20*xzs - 4*xs*zs + ((-4*xs^2 + 20*xss)*
     (-((-4*ys^2 + 20*yys)*(-20*xzs + 4*xs*zs)) + (20*xys - 4*xs*ys)*
       (-20*yzs + 4*ys*zs)))/((-20*xys + 4*xs*ys)^2 - 
     (-4*xs^2 + 20*xss)*(-4*ys^2 + 20*yys)))/(20*xys - 4*xs*ys)}

c:

{(zs + (ys*(-20*xzs + 4*xs*zs))/(20*xys - 4*xs*ys) + 
   ((xs - ((-4*xs^2 + 20*xss)*ys)/(20*xys - 4*xs*ys))*
     (-((-4*ys^2 + 20*yys)*(-20*xzs + 4*xs*zs)) + (20*xys - 4*xs*ys)*
       (-20*yzs + 4*ys*zs)))/((-20*xys + 4*xs*ys)^2 - 
     (-4*xs^2 + 20*xss)*(-4*ys^2 + 20*yys)))/5}

n0 = 6

{-((-((-4*ys^2 + 24*yys)*(-24*xzs + 4*xs*zs)) + (24*xys - 4*xs*ys)*
     (-24*yzs + 4*ys*zs))/((-24*xys + 4*xs*ys)^2 - 
    (-4*xs^2 + 24*xss)*(-4*ys^2 + 24*yys)))}

*)













