(* TODO: had to load info[] lines manually, need to automate this *)

(* after bc-find-vjr.m files are created, glue them back into
mathematica like this:

echo "list = {" >! outputfile.txt
: the -v 'jd' avoids printing the header string
fgrep -h '{' output-for-*.txt | fgrep -v jd |
 perl -nle 'chomp;print "$_,"' >> outputfile.txt
: the 0 line prevents the null error
echo "{0,{0,0,0}}};\n" >> outputfile.txt

(ignore the "null" error, load both outputfile.txt above and the
ephermis for the time period in question, then...)

*)

(* find the maximal separation of Venus/Jupiter/Regulus *)

(* the -1 below is to get rid of the "null" error *)

maxt = Table[{list[[i,1]],Max[list[[i,2]]]}, {i,1,Length[list]-1}];

regulus = earthvecstar[(10+8/60+22.311/3600)/12*Pi,(11+58/60+1.95/3600)*Degree]

(* and the actual formula *)

max[jd_] := Max[{
 VectorAngle[earthvector[jd,jupiter],regulus],
 VectorAngle[earthvector[jd,venus],regulus],
 earthangle[jd,venus,jupiter]
}];

(* find local minima indices in maxt *)

mins =  Select[Range[2,Length[maxt]-1],
 maxt[[#,2]]<=maxt[[#+1,2]] && maxt[[#,2]]<=maxt[[#-1,2]] &];

(* find actual lowest instant *)

mins2 = Table[maxt[[i,1]],{i,mins}];

mins3=Table[ternary[mins2[[i]]-1,mins2[[i]]+1,max,10^-9],{i,1,Length[mins2]}];

(* format as degrees and days *)

fjd[jd_] := DateList[(jd-2415020.5)*86400];

mins4 = Table[{fjd[mins3[[i,1]]],Round[mins3[[i,2]]/Degree,1/1000.]}, 
 {i,1,Length[mins3]}];

mins5 = Sort[mins4, #1[[2]]  < #2[[2]] &];

mins6 = Select[mins5, #1[[2]] <= 5.5&];



mins =  Sort[Table[{maxt[[i,1]],Round[maxt[[i,2]]/Degree,.01]}, 
{i,Select[Range[2,Length[maxt]-1],
maxt[[#,2]]<=maxt[[#+1,2]] && maxt[[#,2]]<=maxt[[#-1,2]] &]}],
#1[[2]] < #2[[2]] &];

mins =  Sort[Table[{fjd[maxt[[i,1]]],Round[maxt[[i,2]]/Degree,.01]}, 
{i,Select[Range[2,Length[maxt]-1],
maxt[[#,2]]<=maxt[[#+1,2]] && maxt[[#,2]]<=maxt[[#-1,2]] &]}],
#1[[2]] < #2[[2]] &];

*)
