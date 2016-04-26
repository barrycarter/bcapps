(* 

Is relativitiy really a geometric theory?

NOTE: time then distance

*)


pos[earth][t_][v_] = relativityMatrix[v].{8,t}
pos[star][t_][v_] = relativityMatrix[v].{0,t}
pos[ship][t_][v_] = relativityMatrix[v].{0.8*t,t}

t[v_] = Table[Point[pos[i][t][v]], {i, {earth,star,ship}}, {t,0,10}];

star[v_] = Line[{pos[star][0][v], pos[star][20][v]}];


t2[v_] = {
 RGBColor[0,0,1],
 Line[{pos[earth][0][v], pos[earth][10][v]}],
 RGBColor[1,0,0],
 Line[{pos[ship][0][v], pos[ship][10][v]}],
};

t3[v_] = {RGBColor[0,0,1], Dashed, 
 Table[Line[{pos[earth][t][v], pos[star][t+8][v]}], {t,0,10}]};


Graphics[{t2[0], t[0]}, Axes -> True, AxesLabel -> {"x", "t"}]
showit

Graphics[{t2[0], t[0], t3[0], star[0]}, Axes -> True, AxesLabel -> {"x", "t"}]
showit

Graphics[{t2[-0.8], t[-0.8], t3[-0.8]}, Axes -> True, AxesLabel -> {"x", "t"}]
showit


m = relativityMatrix[.6];

t1 = Table[Arrow[{{t, 0}, temp1405.{t,0}}], {t,0,10}]

t2 = Table[Arrow[{{0, x}, temp1405.{0,x}}], {x,0,10}]

t3 = Table[Arrow[{{0, x}, temp1405.{0,x}-{0,x}}], {x,0,10}]

Graphics[Union[t1,t2]]

t = Table[{
 Line[{{0, i}, {10, i}}],
 Line[{{i, 0}, {i, 10}}],
 Line[{m.{0, i}, m.{10, i}}],
 Line[{m.{i, 0}, m.{i, 10}}]
}, {i,-10,10}];

t1 = Table[{
 Line[{{-10, i}, {10, i}}],
 Line[{{i, -10}, {i, 10}}]
}, {i,-10,10}];

t2 = Table[{
 Line[{m.{-20, i}, m.{20, i}}],
 Line[{m.{i, -20}, m.{i, 20}}]
}, {i,-20,20}];

g2 = Graphics[
 {
 RGBColor[1,0.5,0],
 Arrow[{{5,3}, {10,8}}],
 RGBColor[0,0,0], t1,
 RGBColor[1,0,0], t2,
 RGBColor[0,0,1],
 Line[{{0,0}, {10,6}}],
}]

Show[g2, Axes -> True, PlotRange -> 10]
showit



