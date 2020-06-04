<formulas>

include("/home/user/BCGIT/bclib.jl")

# TODO: don't load from tmp file

mars = CSV.read("/tmp/mars2.txt", header = false);

decs = mars[:,1];

</formulas>

