import numpy as np
import pandas as pd
from sklearn.linear_model import LinearRegression
import netCDF4 as nc

ds = nc.Dataset('myfile.nc')

lats, depths, lons, times = np.meshgrid(ds.variables['lat'][:], ds.variables['depth'][:], ds.variables['lon'][:], ds.variables['time'][:])

lats = lats.flatten()
depths = depths.flatten()
lons = lons.flatten()
times = times.flatten()

df = pd.DataFrame({
 'lat': lats, 'depth': depths, 'lon': lons, 'time': times,
  'thetao': ds.variables['thetao'][:].flatten()
})

x = df[['depth', 'lon', 'time', 'lat']].values
y = df['thetao'].values

mask = ~np.isnan(y).any(axis=0)

reg = LinearRegression()

reg.fit(x[mask],y[mask])

print(reg)

# x = df[['lat', 'lon', 'depth', 'time']].values
# y = df['thetao'].values



# print(pd.DataFrame(ds))

# print(df)

# print(df['depth'])

# print(ds.variables)

# print(ds['lat'])



