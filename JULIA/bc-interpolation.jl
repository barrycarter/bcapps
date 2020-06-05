<formulas>

include("/home/user/BCGIT/bclib.jl")

# TODO: don't load from tmp file

# mars = CSV.read("/tmp/mars2.txt", header = false);

mars = CSV.read(`bzcat /home/user/20200604/mars-dec-per-hour.txt.bz2`, header = false);

decs = mars[:,1];

</formulas>

t1552 = splitArray(Dict("arr" => decs, "n" => 10))

t1554 = list2NormalPoly(Dict("deg" => 4, "arr" => t1552["arrarr"][4]))

# SEE BELOW: t1558 = map(x -> list2NormalPoly(Dict("deg" => 4, "arr" => x)), t1552["arrarr"])

t1558 = map(x -> list2NormalPoly(Dict("deg" => 4, "arr" => x))["maxres"], 
  t1552["arrarr"])

t1602 = splitArray(Dict("arr" => decs, "n" => 1000))

t1603 = map(x -> list2NormalPoly(Dict("deg" => 4, "arr" => x))["maxres"], 
  t1602["arrarr"])

TODO: functionalize, minimize (degree+1)*(number of pieces)










