(* http://astronomy.stackexchange.com/questions/10979/moons-orbit-around-the-sun *)


ParametricPlot[{93*Cos[t*Degree],93*Sin[t*Degree]},{t,0,360}]

ParametricPlot[{1*Cos[12*t*Degree],1*Sin[12*t*Degree]},{t,0,360}]

ParametricPlot[{93*Cos[t*Degree]+5*Cos[120*t*Degree],
                93*Sin[t*Degree]+5*Sin[120*t*Degree]},{t,0,360}]


PolarPlot[93,{t,0,360*Degree}]

PolarPlot[93+5*Sin[10*t],{t,0,360*Degree}]

PolarPlot[93+15*Sin[10*t],{t,0,360*Degree}]

PolarPlot[{93,93+50*Sin[10*t]},{t,0,360*Degree}]

PolarPlot[{93,93+70*Sin[10*t]},{t,0,360*Degree}]

PolarPlot[{93,93+1*Sin[10*t]},{t,0,360*Degree}]

PolarPlot[{93,93+10*Sin[360*t]},{t,0,4*Degree}]
