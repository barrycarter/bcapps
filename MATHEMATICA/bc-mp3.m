(* these should be identical up to volume *)

m1 = Import["/home/user/MP3/MP3-TMP/everyspermissacred.mp3"]
m2 = Import["/home/user/MP3/EverySpermIsSacred.mp3"]

(* they look similar *)

AudioPlot[m1]
AudioPlot[m2]

(* number of samples *)

AudioLength[m1]

(* how long it is *)

Duration[m1]

AudioData[m1]

list1 = AudioData[m1];
list2 = AudioData[m2];

(* 2 channels so 2 x samples list *)

Take[list1[[1]], 50]
Take[list2[[1]], 50]


t1246 = AudioData[m1, "SignedInteger32"];



