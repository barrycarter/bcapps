wti =
TimeSeries[Import["https://www.eia.gov/dnav/pet/hist_xls/RWTCd.xls",
"XLS"][[2, 4 ;; -2]]];

wti = TimeSeriesMap[Quantity[#, "USDollars"] &, wti]

DateListPlot[wti]

(* don't have sufficients version to help *)


