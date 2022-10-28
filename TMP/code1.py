import shapefile

sf = shapefile.Reader("/tmp/ne_10m_admin_0_countries.shp")

print(len(sf.shapes()))

for i in range(0, len(sf.shapes())-2):
    for j in range(i+1, len(sf.shapes())-1):
        print(sf.shapes()[i],sf.shapes()[j])

exit(0)

# graticule = read_file("../data/natural-earth/ne_110m_graticules_5.shp")
# print(len(world.columns))

# extract the country rows as a GeoDataFrame object with 1 row
usa = world.loc[(world.ISO_A3 == 'USA')]
mex = world.loc[(world.ISO_A3 == 'MEX')]
# print(type(usa))

# extract the geometry columns as a GeoSeries object
usa_col = usa.geometry
mex_col = mex.geometry
# print(type(usa_col))

# extract the geometry objects themselves from the GeoSeries
usa_geom = usa_col.iloc[0]
mex_geom = mex_col.geometry.iloc[0]
# print(type(mex_geom))

# calculate intersection
border = usa_geom.intersection(mex_geom)

# initialise a variable to hold the cumulative length
cumulative_length = 0

# loop through each segment in the line
for segment in border.geoms:

    # calculate the forward azimuth, backward azimuth and direction of the current segment
    distance = g.inv(segment.coords[0][0], segment.coords[0][1],
                    segment.coords[1][0], segment.coords[1][1])[2]

    # add the distance to our cumulative total
    cumulative_length += distance

    print(cumulative_length)
    print(f"Border Length:{cumulative_length:,.2f}m")

