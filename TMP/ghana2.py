import matplotlib.pyplot as plt
import shapefile

sf = shapefile.Reader("gadm41_GHA_0.shp")

shps = sf.shapes()
poly = shps[0].points

x = [point[0] for point in poly]
y = [point[1] for point in poly]

plt.plot(x,y)
plt.show()
