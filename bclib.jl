import Pkg, Plots, CSV, GLM, DataFrames, Polynomials, StatsBase;


#== splitArray(arr, n)

Splits arr into n equal sized pieces plus 1 extra piece that is smaller

Returns an array of arrays

=#

function splitArray(arr, n)

   ret = [];
   len = length(arr);
   clen = floor(len/n);
   st = 1;

   while st < len
      en = convert(Int, st + clen - 1)
      if en > len en = len end
      push!(ret, arr[st:en])
      st = convert(Int, st + clen)
   end

   ret
end



