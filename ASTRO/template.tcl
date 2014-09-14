# a template to query HORIZONS
# required: $target, $sdate, $edate, $interval
spawn telnet horizons.jpl.nasa.gov 6775
expect "Horizons> " {send "page\n"}
# the target body
expect "Horizons> " {send "$target\n"}
# for now, assuming I always want a vector-based ephermis
expect "phemeris" {send "e\n"}
expect "Vectors" {send "v\n"}
# for now, always viewing from SSB
expect "Coordinate center" {send "@0\n"}
# for now, assuming frame coords (consistent w Chebyshev)
expect "Reference plane" {send "frame\n"}
# start and end dates, in dd-mmm-yyyy format (many others also OK)
expect "Starting CT"  {send "$sdate\n"}
expect "Ending   CT"  {send "$edate\n"}
# interval..
expect "Output interval" {send "$interval\n"}
# accept and terminate
expect "Accept default output" {send "y\n"}
expect "Select..." {send "q\n"}
