import gdal
import numpy as np
from scipy.spatial.distance import pdist

# Open the geotiff file
ds = gdal.Open('/mnt/villa/user/NOBACKUP/EARTHDATA/POPULATION/gpw_v4_national_identifier_grid_rev11_1_deg.tif')

# Read in the data from the geotiff
data = ds.ReadAsArray()

# Select only the pixels with the desired value
value = 123
mask = (data == value)
filtered_data = data[mask]

# Compute the distance matrix
distance_matrix = pdist(filtered_data)

# Save the distance matrix to a file
np.savetxt('distance_matrix.txt', distance_matrix)
