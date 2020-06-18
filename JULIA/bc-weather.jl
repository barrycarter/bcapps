# NOTE: CSVFiles and CSV are different!

import Pkg;
Pkg.add("Plots"); Pkg.add("CSV"); Pkg.add("GLM"); Pkg.add("DataFrames");
Pkg.add("Polynomials"); Pkg.add("StatsBase"); Pkg.add("Glob");
Pkg.add("CSVFiles");


import Pkg, Plots, CSV, GLM, DataFrames, Polynomials, StatsBase, Glob;
import CSVFiles;

# weather stuff

files = Glob.glob("/mnt/kemptown/NOBACKUP/EARTHDATA/CLIMATE/WEATHER/isd-lite/*/723650-23050-????.gz")

files = Glob.glob("*/723650-23050-????.gz", 
 "/mnt/kemptown/NOBACKUP/EARTHDATA/CLIMATE/WEATHER/isd-lite/")

fileNames = string("`", "zcat", join(files, " "), "`")

abqWeather = CSV.read(fileNames, header = false);

t1932 = string("gzip -dc ", join(files[1:5], " "))


t1930 = `$t1932`

t1933 = CSV.read(t1930, header = false);




abqWeather = CSV.read(string("`", "zcat ", files[4], "`"))








# abqWeather = CSV.read(`zcat /mnt/kemptown/NOBACKUP/EARTHDATA/CLIMATE/WEATHER/isd-lite/*/723650-23050-????.gz`);

# abqWeather = CSV.read(`zcat "/mnt/kemptown/NOBACKUP/EARTHDATA/CLIMATE/WEATHER/isd-lite/*/723650-23050-????.gz"`);

# abqWeather = CSV.read(`glob /mnt/kemptown/NOBACKUP/EARTHDATA/CLIMATE/WEATHER/isd-lite/*/723650-23050-????.gz`);

abqWeather = CSV.read(`echo /mnt/kemptown/NOBACKUP/EARTHDATA/CLIMATE/WEATHER/isd-lite/*/723650-23050-????.gz`);

# works

CSV.read(`gzip -dc /mnt/kemptown/NOBACKUP/EARTHDATA/CLIMATE/WEATHER/isd-lite/1941/723650-23050-1941.gz`)

# fails

CSV.read(`"gzip -dc /mnt/kemptown/NOBACKUP/EARTHDATA/CLIMATE/WEATHER/isd-lite/1941/723650-23050-1941.gz"`)

# works

t1938 = "date"

CSV.read(`$t1938`, header = false)

# other

t1943 = string("/bin/gzip -dc ", join(files[1:2], " "))

CSV.read(`$t1943`, header = false)

# below works!!!

abqWeather = CSV.read(`gzip -dc $files` , header = false);

# above is about 654539 lines w lots of ugly errors

# no errors (and fairly fast) once I turned `header = false`

# below = lots of errors, but each val is sep col as desired

abqWeather = CSV.read(`gzip -dc $files`, header = false, delim = ' ');

t2003 = DataFrames.groupby(abqWeather, [2,3,4])

# t2003[555] is now all data for 8/29 04:00

# t2003[555]["Column3"] (not what I want?)

# StatsBase.mean(t2003[555]["Column7"])

# for row 1, below is the mmddhh (actually its for all of them)

t2003[555][1,2]*10000 + t2003[555][1,3]*100 + t2003[555][1,4]

# t2003[555][7] is a list of temps (?)

# from file: Field 6: Pos 20-24, Length 6: Dew Point Temperature

# from file: Field 5: Pos 14-19, Length 6:  Air Temperature

# NOTE: THIS IS NOT WORKING, IT TREATS MULTIPLE SPACES AS MULTIPLE SPACES ARGH

abqWeather = DataFrames.read_table(
 `gzip -dc $files`, header = false, delim = ' '
);

# abqWeather = CSV.read(`gzip -dc $files`, header = false, spacedelim = true);

df = DataFrame(load(`gzip -dc $files`, header = false, spacedelim = true));

t2033 = CSVFiles.load(`gzip -dc $files`, header = false, spacedelim = true);

t2034 = run(`gzip -dc $files`);

















