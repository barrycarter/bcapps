(* given the annotated conjunctions, dumps to file for Perl parsing *)

outfile = "/home/barrycarter/SPICE/KERNELS/annmsepsdump"<>"-"<>
 ToString[Round[info[jstart]]]<>"-"<>ToString[Round[info[jend]]]<>".txt";

Put[Definition[annminsep],outfile];
