import Pkg;
Pkg.add("Plots"); Pkg.add("CSV"); Pkg.add("GLM"); Pkg.add("DataFrames");
Pkg.add("Polynomials"); Pkg.add("StatsBase"); Pkg.add("Glob")

import Pkg, Plots, CSV, GLM, DataFrames, Polynomials, StatsBase, Glob;

# weather stuff

# abqWeather = CSV.read(`zcat /mnt/kemptown/NOBACKUP/EARTHDATA/CLIMATE/WEATHER/isd-lite/*/723650-23050-????.gz`);

# abqWeather = CSV.read(`zcat "/mnt/kemptown/NOBACKUP/EARTHDATA/CLIMATE/WEATHER/isd-lite/*/723650-23050-????.gz"`);

# abqWeather = CSV.read(`glob /mnt/kemptown/NOBACKUP/EARTHDATA/CLIMATE/WEATHER/isd-lite/*/723650-23050-????.gz`);

abqWeather = CSV.read(`echo /mnt/kemptown/NOBACKUP/EARTHDATA/CLIMATE/WEATHER/isd-lite/*/723650-23050-????.gz`);







