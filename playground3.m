(* solar radiation http://pveducation.org/pvcdrom/properties-of-sunlight/calculation-of-solar-insolation *)


f[theta_] = 1.353*(0.7^((1/Cos[theta])^0.678))

ArcCos[1/((Log[1/1.353]/Log[0.7])^(1/0.678))]/Degree




