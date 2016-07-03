(*

https://www.quora.com/Which-country-location-has-minimum-temperature-variation-throughout-the-year

https://www.quora.com/unanswered/Which-city-has-the-minimum-temperature-of-22-C-and-doesnt-go-much-below-it-and-has-a-maximum-temperature-of-27-C-and-doesnt-go-much-above-it-almost-throughout-the-year

*)

temp2042 = WeatherData["Albuquerque", "Temperature", { {1986,7,1}, 
{2016,6,30}}];

temp2044 = WeatherData["Boston", "Temperature", { {1986,7,1}, 
{2016,6,30}}];

(* takes about 25s to get 30y of data per location *)

temp2049 = WeatherData["Boston", "Temperature", 
 {{2015,7,1}, {2016,6,30}, "Hour"}];


TODO: note SJSU

(* this test is for 10 years, really do 30 years *)

sdate = {2006,7,1};
edate = {2016,6,30};

kbos = WeatherData["Boston", "Temperature", {sdate,edate}];

kbos2 = N[Table[{(FromDate[i[[1]]]-FromDate[sdate])/3600, i[[2]]}, {i, kbos}]];


kbos2 = DeleteDuplicates[
Table[{(FromDate[i[[1]]]-FromDate[sdate])/3600, i[[2]]}, {i, kbos}],
#1[[1]] == #2[[1]] &];

kbos3 = Union[kbos, SameTest -> (#1[[1]] == #2[[1]] &)];





