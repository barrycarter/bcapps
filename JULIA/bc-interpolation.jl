<formulas>

include("/home/user/BCGIT/bclib.jl")

# TODO: don't load from tmp file

# mars = CSV.read("/tmp/mars2.txt", header = false);

marsDec = CSV.read(`bzcat /home/user/20200604/mars-dec-per-hour.txt.bz2`, header = false);

marsRA = CSV.read(`bzcat /home/user/20200604/mars-ra-per-hour.txt.bz2`, header = false);

decs = marsDec[:,1];

ras = marsRA[:,1];

ranew = [ras[1]];

for i in 2:length(ras)
 delta = ras[i] - ras[i-1]
 if delta > 180 delta -= 360 end
 if delta < -180 delta += 360 end
 push!(ranew, ranew[i-1] + delta)
end

</formulas>

TODO: fix docs to say obj["key"], not obj.key, since latter will not
work in Julia

TODO: format same way as solar ra and dec (and moon?)

#=

obj.arr = full array
obj.deg = degree of polynomial
obj.n = split into n pieces

=#

function maxResidual(obj)

  ret = Dict()

  ret["split"] = splitArray(Dict("arr" => obj["arr"], "n" => obj["n"]))

  ret["polys"] = map(x -> list2NormalPoly(Dict("deg" => obj["deg"], "arr" => x)), ret["split"]["arrarr"])

  ret["maxres"] = maximum(map(x -> x["maxres"], ret["polys"]))

  ret

end

maxResidual(Dict("arr" => ranew, "n" => 5, "deg" => 2))



list2NormalPoly(Dict("deg" => 1, "arr" => ranew))







t1552 = splitArray(Dict("arr" => decs, "n" => 10))

t1554 = list2NormalPoly(Dict("deg" => 4, "arr" => t1552["arrarr"][4]))

# SEE BELOW: t1558 = map(x -> list2NormalPoly(Dict("deg" => 4, "arr" => x)), t1552["arrarr"])

t1558 = map(x -> list2NormalPoly(Dict("deg" => 4, "arr" => x))["maxres"], 
  t1552["arrarr"])

t1602 = splitArray(Dict("arr" => decs, "n" => 1000))

t1603 = map(x -> list2NormalPoly(Dict("deg" => 4, "arr" => x))["maxres"], 
  t1602["arrarr"])

TODO: functionalize, minimize (degree+1)*(number of pieces)










