(*

Manhattan map image (1816x8160) having following lat/lon of corners.

TopLeft: (-73.9308,40.8883)
TopRight: (-73.8584,40.858)
BottomLeft: (-74.0665,40.7024)
BottomRight: (-73.9944,40.6718)

*)

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


