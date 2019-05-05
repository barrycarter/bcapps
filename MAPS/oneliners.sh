# run this inside GRASS shell to see how long it takes to create
# psuedo-slippy tiles without rasterizing ahead of time

echo date
perl -le 'for $lng (-120..-105) {for $lat (30..40) {$n = $lat+1; $e = $lng+1; print "g.region n=$n s=$lat w=$lng e=$e rows=256 cols=256\nv.to.rast --overwrite input=ne_10m_time_zones output=temp_$lng_$lat rgb_column=rgb use=cat\nr.out.gdal --overwrite input=temp_$lng_$lat output=/tmp/GDAL$lng$lat.png format=PNG"}}'
echo date

# 38 seconds for 176 PNGs or 0.216 seconds per PNG

