<formulas>

include("/home/user/BCGIT/bclib.jl")

# TODO: don't load from tmp file

# mars = CSV.read("/tmp/mars2.txt", header = false);

mars = CSV.read(`bzcat /home/user/20200604/mars-dec-per-hour.txt.bz2`, header = false);

decs = mars[:,1];

</formulas>

