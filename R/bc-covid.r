# run this: R --no-restore-data --save

# one off package loading:

# install.packages("rlist");

library(rlist);
library(pipeR);
library(sqldf);

> sqldf("SELECT country, GROUP_CONCAT(deaths) FROM deaths GROUP BY country");

> sqldf("SELECT Country, GROUP_CONCAT(deaths) FROM deaths GROUP BY country LIMIT 5");

> sqldf("SELECT Country, SUM(deaths) FROM deaths GROUP BY country ORDER BY SUM(deaths) DESC");


# https://cran.r-project.org/

# this is a comment

deaths = read.csv("/home/user/covid-19/data/countries-aggregated.csv",
stringsAsFactors=FALSE);

deaths = read.csv("/home/user/covid-19/data/countries-aggregated.csv", sep=",");

deaths = read.csv("/home/user/covid-19/data/countries-aggregated.csv", sep=",");

deaths2 = t(deaths);

t2044 = list.group(deaths, "Country");

t2053 = list.group(deaths, .["Country"]);

deaths[, 1]



countries = unique(deaths["Country"]);

# subset(deaths, 

subset(deaths, Country == "Sweden", Deaths);




# browser();

# WANT: deaths(country name) = list of deaths by day

# list of dates

deaths$Date
deaths["Date"]
deaths[1]

# row.names(trees) = c("birch", "ash", "sycamore", 4:31);



# rm(var) to remove value of var





