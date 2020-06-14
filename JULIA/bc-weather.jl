import Pkg;
Pkg.add("Plots"); Pkg.add("CSV"); Pkg.add("GLM"); Pkg.add("DataFrames");
Pkg.add("Polynomials"); Pkg.add("StatsBase"); Pkg.add("Glob")

import Pkg, Plots, CSV, GLM, DataFrames, Polynomials, StatsBase, Glob;

# weather stuff

files = Glob.glob("/mnt/kemptown/NOBACKUP/EARTHDATA/CLIMATE/WEATHER/isd-lite/*/723650-23050-????.gz")

files = Glob.glob("*/723650-23050-????.gz", 
 "/mnt/kemptown/NOBACKUP/EARTHDATA/CLIMATE/WEATHER/isd-lite/")

fileNames = string("`", "zcat", join(files, " "), "`")

abqWeather = CSV.read(fileNames, header = false);

t1932 = string("zcat ", join(files[1:5], " "))


t1930 = `$t1932`

t1933 = CSV.read(t1930, header = false);




abqWeather = CSV.read(string("`", "zcat ", files[4], "`"))








# abqWeather = CSV.read(`zcat /mnt/kemptown/NOBACKUP/EARTHDATA/CLIMATE/WEATHER/isd-lite/*/723650-23050-????.gz`);

# abqWeather = CSV.read(`zcat "/mnt/kemptown/NOBACKUP/EARTHDATA/CLIMATE/WEATHER/isd-lite/*/723650-23050-????.gz"`);

# abqWeather = CSV.read(`glob /mnt/kemptown/NOBACKUP/EARTHDATA/CLIMATE/WEATHER/isd-lite/*/723650-23050-????.gz`);

abqWeather = CSV.read(`echo /mnt/kemptown/NOBACKUP/EARTHDATA/CLIMATE/WEATHER/isd-lite/*/723650-23050-????.gz`);







