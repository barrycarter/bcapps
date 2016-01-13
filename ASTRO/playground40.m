(* Fourier oddness w/ declination *)

sd = Table[AstronomicalData["Sun", {"Declination", DateList[t]}],
 {t, 3155716800, 3155716800+86400*365.2425*10, 86400}];





