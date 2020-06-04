import Pkg, Plots, CSV, GLM, DataFrames, Polynomials, StatsBase;

#== list2NormalPoly(obj)

Given an array obj.arr and a degree obj.deg, return the polynomial
poly of degree deg that best fits the array, treating the domain as
[-1, 1] (inclusive), the residuals (residuals), the remapped domain
(count), and the maxium absolute residual (maxres)

Sample usage: list2NormalPoly(Dict("deg" => 2, "arr" => [1,2,3]))

=#

function list2NormalPoly(obj)
   dict = Dict();
   dict["count"] = range(-1, 1, step=2/(length(obj["arr"])-1));
   dict["poly"] = Polynomials.fit(dict["count"], obj["arr"], obj["deg"]);
   dict["residuals"] = map(dict["poly"], dict["count"]) - obj["arr"];
   dict["maxres"] = maximum(map(abs, dict["residuals"]));
   dict;
end

#== splitArray(obj)

Splits obj.arr into obj.n equal sized pieces plus 1 extra piece (if
needed) that is smaller

Returns an array of arrays and the length of each subarray

=#

function splitArray(obj)

   dict = Dict();
   dict["arrarr"] = [];
   len = length(obj["arr"]);
   clen = dict["pieceLength"] = floor(len/obj["n"]);
   st = 1;

   while st <= len
      en = convert(Int, st + clen - 1)
      if en > len en = len end
      push!(dict["arrarr"], obj["arr"][st:en])
      st = convert(Int, st + clen)
   end

   dict;
   
end



