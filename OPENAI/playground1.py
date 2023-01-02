import shapefile

# don't have, can't install
# import geopandas

sf = shapefile.Reader("output.shp")

# Get the fields and records from the Shapefile
fields = sf.fields[1:]
records = sf.records()

# Iterate over the records
for record in records:
    # Print the attributes of the record
    print(record)
    # Get the geometry of the record
#    shape = sf.shape(record)
    # Print the geometry of the record
#    print(shape.points)
