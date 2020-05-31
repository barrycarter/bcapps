# run this: R --no-restore-data --save

# one off package loading:

# install.packages("rlist");
# install.packages("pipeR");
# install.packages("sqldf");

library(rlist);
library(pipeR);
library(sqldf);

# NOTES:

# View(df) to view dataframe
# summary(df) and names(df) and str(df) also useful

# class(object)
# typeof(object)
# dim(object)

# data[2] is the second COLUMN

# data[3,2] is the third row second column

# data[2][,1][14] same as data[14,2];

# read the data

data = read.csv("/home/user/covid-19/data/countries-aggregated.csv",
stringsAsFactors=FALSE);

# get the list of countries

countries = unique(data["Country"][,1]);

# get the list of days

days = unique(data["Date"][,1]);

# create df for deaths

deaths = data.frame(days);

for (i in countries) {
 deaths[i] = subset(data, Country == i, Deaths)[,1];
}

deaths["index"] = c(1:length(days));

# plot(deaths["Sweden"][,1]);

# plot(deaths["index"], deaths["Sweden"]);


# example subset

# subset(data, Country == "Sweden", Deaths);

# deaths = c();
# deaths[""] = days;

# deaths = array();


# > sqldf("SELECT country, GROUP_CONCAT(deaths) FROM deaths GROUP BY country");

# > sqldf("SELECT Country, GROUP_CONCAT(deaths) FROM deaths GROUP BY country LIMIT 5");

# > sqldf("SELECT Country, SUM(deaths) FROM deaths GROUP BY country ORDER BY SUM(deaths) DESC");


# https://cran.r-project.org/

# this is a comment

# deaths = read.csv("/home/user/covid-19/data/countries-aggregated.csv", sep=",");

# deaths = read.csv("/home/user/covid-19/data/countries-aggregated.csv", sep=",");

# deaths2 = t(deaths);

# t2044 = list.group(deaths, "Country");

# t2053 = list.group(deaths, .["Country"]);

# deaths[, 1]




# subset(deaths, 

# subset(deaths, Country == "Sweden", Deaths);




# browser();

# WANT: deaths(country name) = list of deaths by day

# list of dates

# deaths$Date
# deaths["Date"]
# deaths[1]

# row.names(trees) = c("birch", "ash", "sycamore", 4:31);



# rm(var) to remove value of var





