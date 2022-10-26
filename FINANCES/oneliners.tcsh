# compute historical return two ways

if $argv[1] == 1 then

perl -F, -anle 'if ($F[3] > 0 && $F[1] > $F[3]) {$tot+=log($F[1])-log($F[3]); print exp($tot)}' ~/Downloads/HistoricalData_1666778668871.csv

endif

if $argv[1] == 2 then

perl -F, -anle 'sub BEGIN {$tot=1;} if ($F[3] > 0 && $F[1] > $F[3]) {$tot*=$F[1]/$F[3]; print $tot}' ~/Downloads/HistoricalData_1666778668871.csv

endif

