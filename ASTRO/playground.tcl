#!/usr/bin/expect

spawn telnet horizons.jpl.nasa.gov 6775
expect "Horizons> " {send "page\n"}
expect "Horizons> " {send "599\n"}
expect "phemeris" {send "e\n"}
expect "Vectors" {send "v\n"}
expect "Coordinate center" {send "@0\n"}
expect "Reference plane" {send "frame\n"}
expect "Starting CT"  {send "14-Sep-2014\n"}
expect "Ending   CT"  {send "14-Oct-2014\n"}
expect "Output interval" {send "1d\n"}
expect "Accept default output" {send "y\n"}
expect "Select..." {send "q\n"}
