# run this: R --no-restore-data --save

# one off package loading:

# install.packages("rlist");

library(rlist);
library(pipeR);

# https://cran.r-project.org/

# this is a comment

deaths = read.csv("/home/user/covid-19/data/countries-aggregated.csv");

countries = unique(deaths["Country"]);

# subset(deaths, 

subset(deaths, Country == "Sweden", Deaths);

list.group(deaths, Country);


# browser();

# WANT: deaths(country name) = list of deaths by day

# list of dates

deaths$Date
deaths["Date"]
deaths[1]

# row.names(trees) = c("birch", "ash", "sycamore", 4:31);



# rm(var) to remove value of var





