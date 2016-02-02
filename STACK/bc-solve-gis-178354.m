(*

Manhattan map image (1816x8160) having following lat/lon of corners.

TopLeft: (-73.9308,40.8883)
TopRight: (-73.8584,40.858)
BottomLeft: (-74.0665,40.7024)
BottomRight: (-73.9944,40.6718)

*)

(* 

pixel conversion check; for sample map this is:

top left -> 2223,0

top right -> 3437, 654

bottom left -> 1, 4119

bottom right -> 1215, 4774

initial image coords: 1380x4682

final image coords: 3438x4776

*)

angle = 28.34*Degree

{x-1380/2, y-4682/2}

convert[x_,y_] = Take[rotationMatrix[z, angle].{x-1380/2,y-4682/2,0},2]

Clear[angle,cx,cy];
angle = 28.34*Degree
cx = 1380/2
cy = 4682/2

step1[x_,y_] = Take[rotationMatrix[z, angle].{x-cx,y-cy,0},2]

trans = 
 Table[Arrow[{{i,j},step1[i,j]}], {i,{0,cx,cx*2}}, {j,{0,cy,cy*2}}]
Graphics[trans]
showit

test[x_,y_] = step1[x,y] + {step1[cx*2,0][[1]], step1[cx*2,cy*2][[2]]}

trans = 
 Table[Arrow[{{i,j},test[i,j]}], {i,{0,cx,cx*2}}, {j,{0,cy,cy*2}}]
Graphics[trans]
showit



points =
 Partition[Flatten[Table[step1[i,j], {i,{0,cx,cx*2}}, {j,{0,cy,cy*2}}]],2]

convert[x_,y_] = step1[x,y] + Abs[step1[0,0]]

points2 =
 Partition[Flatten[Table[convert[i,j], {i,{0,cx,cx*2}}, {j,{0,cy,cy*2}}]],2]




ListPlot[frame]














convert[0,0]

convert[x_,y_] = Take[rotationMatrix[z, angle].{x,y,0},2]


xy2ll[x_, 1] = {-73.9308+ x*(-73.8584+73.9308)/1815,
                40.8883 + x*(40.858-40.8883)/1815};

xy2ll[x_,8160] = {-74.0665 + x*(-73.9944+74.0665)/1815,
                  40.7024 + x*(40.6718-40.7024)/1815};

xy2ll[x_,y_] = xy2ll[x,1] + y/8159*(xy2ll[x,8160]-xy2ll[x,1])

xy2ll[x_,y_] = Chop[Expand[xy2ll[x,1] + y/8159*(xy2ll[x,8160]-xy2ll[x,1])]]

xy2ll[1,1]
xy2ll[1816,1]
xy2ll[1,8160]
xy2ll[1816,8160]

s = Solve[{xy2ll[x,y][[1]] == lon, xy2ll[x,y][[2]] == lat}, {x,y}]

x[lon_,lat_] = x /. s[[1,1]]
y[lon_,lat_] = y /. s[[1,2]]

x[-73.9308,40.8883]
x[-73.9944,40.6718]


p1 = ParametricPlot[{x[40.8,lon],-y[40.8,lon]}, {lon, -75,-73}]
p2 = ParametricPlot[{x[lat,-74],-y[lat,-74]}, {lat, 40,41}]
Show[{p1,p2}, AspectRatio -> Automatic]
showit




xy2ll[930,3590]

test[x_,y_] = {-73.9308 + 0.0000398678*x - 0.0000166299*y,
 40.8883 - 0.000016685*x - 0.0000227819*y}




m = Table[a[i][j],{i,1,2},{j,1,2}];

(* four corners compared to middle value *)

mid = {-73.9308+

Solve[{
 m.{0,0} = {-73.9308,40.8883}
}, m];


