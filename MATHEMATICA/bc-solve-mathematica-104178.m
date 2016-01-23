(* lookup nearest physical constants; highly inefficient, loops thru
entire list *)

nearestPhysicalConstant[x_] := Module[{},
 Return[
Sort[Table[{i, MantissaExponent[x][[1]] - MantissaExponent[i[[2]]][[1]]},
 {i, physicalConstants}],  Abs[#1[[2]]] < Abs[#2[[2]]] &]]];

(*
DumpSave["/home/barrycarter/BCGIT/MATHEMATICA/nearestPhysicalConstant.mx",
{nearestPhysicalConstant, physicalConstants}];
*)

(*

I've now added the literal output of bc-solve-mathematica-104178.pl
below, since the MX file doesn't appear to be
cross-platform/cross-version. I'm not sure this is the best approach,
since I may add others lists of constants later, but, for now, this
will allow everyone to use this "package"

*)

physicalConstants = {};
physicalConstants = Append[physicalConstants, {"{220} lattice spacing of silicon",
  192.0155714*10^-12,0.0000032*10^-12,m}];
physicalConstants = Append[physicalConstants, {"alpha particle-electron mass ratio",
  7294.29954136,0.00000024,1}];
physicalConstants = Append[physicalConstants, {"alpha particle mass",
  6.644657230*10^-27,0.000000082*10^-27,kg}];
physicalConstants = Append[physicalConstants, {"alpha particle mass energy equivalent",
  5.971920097*10^-10,0.000000073*10^-10,J}];
physicalConstants = Append[physicalConstants, {"alpha particle mass energy equivalent in MeV",
  3727.379378,0.000023,MeV}];
physicalConstants = Append[physicalConstants, {"alpha particle mass in u",
  4.001506179127,0.000000000063,u}];
physicalConstants = Append[physicalConstants, {"alpha particle molar mass",
  4.001506179127*10^-3,0.000000000063*10^-3,kg*mol^-1}];
physicalConstants = Append[physicalConstants, {"alpha particle-proton mass ratio",
  3.97259968907,0.00000000036,1}];
physicalConstants = Append[physicalConstants, {"Angstrom star",
  1.00001495*10^-10,0.00000090*10^-10,m}];
physicalConstants = Append[physicalConstants, {"atomic mass constant",
  1.660539040*10^-27,0.000000020*10^-27,kg}];
physicalConstants = Append[physicalConstants, {"atomic mass constant energy equivalent",
  1.492418062*10^-10,0.000000018*10^-10,J}];
physicalConstants = Append[physicalConstants, {"atomic mass constant energy equivalent in MeV",
  931.4940954,0.0000057,MeV}];
physicalConstants = Append[physicalConstants, {"atomic mass unit-electron volt relationship",
  931.4940954*10^6,0.0000057*10^6,eV}];
physicalConstants = Append[physicalConstants, {"atomic mass unit-hartree relationship",
  3.4231776902*10^7,0.0000000016*10^7,E_h}];
physicalConstants = Append[physicalConstants, {"atomic mass unit-hertz relationship",
  2.2523427206*10^23,0.0000000010*10^23,Hz}];
physicalConstants = Append[physicalConstants, {"atomic mass unit-inverse meter relationship",
  7.5130066166*10^14,0.0000000034*10^14,m^-1}];
physicalConstants = Append[physicalConstants, {"atomic mass unit-joule relationship",
  1.492418062*10^-10,0.000000018*10^-10,J}];
physicalConstants = Append[physicalConstants, {"atomic mass unit-kelvin relationship",
  1.08095438*10^13,0.00000062*10^13,K}];
physicalConstants = Append[physicalConstants, {"atomic mass unit-kilogram relationship",
  1.660539040*10^-27,0.000000020*10^-27,kg}];
physicalConstants = Append[physicalConstants, {"atomic unit of 1st hyperpolarizability",
  3.206361329*10^-53,0.000000020*10^-53,C^3*m^3*J^-2}];
physicalConstants = Append[physicalConstants, {"atomic unit of 2nd hyperpolarizability",
  6.235380085*10^-65,0.000000077*10^-65,C^4*m^4*J^-3}];
physicalConstants = Append[physicalConstants, {"atomic unit of action",
  1.054571800*10^-34,0.000000013*10^-34,J*s}];
physicalConstants = Append[physicalConstants, {"atomic unit of charge",
  1.6021766208*10^-19,0.0000000098*10^-19,C}];
physicalConstants = Append[physicalConstants, {"atomic unit of charge density",
  1.0812023770*10^12,0.0000000067*10^12,C*m^-3}];
physicalConstants = Append[physicalConstants, {"atomic unit of current",
  6.623618183*10^-3,0.000000041*10^-3,A}];
physicalConstants = Append[physicalConstants, {"atomic unit of electric dipole mom.",
  8.478353552*10^-30,0.000000052*10^-30,C*m}];
physicalConstants = Append[physicalConstants, {"atomic unit of electric field",
  5.142206707*10^11,0.000000032*10^11,V*m^-1}];
physicalConstants = Append[physicalConstants, {"atomic unit of electric field gradient",
  9.717362356*10^21,0.000000060*10^21,V*m^-2}];
physicalConstants = Append[physicalConstants, {"atomic unit of electric polarizability",
  1.6487772731*10^-41,0.0000000011*10^-41,C^2*m^2*J^-1}];
physicalConstants = Append[physicalConstants, {"atomic unit of electric potential",
  27.21138602,0.00000017,V}];
physicalConstants = Append[physicalConstants, {"atomic unit of electric quadrupole mom.",
  4.486551484*10^-40,0.000000028*10^-40,C*m^2}];
physicalConstants = Append[physicalConstants, {"atomic unit of energy",
  4.359744650*10^-18,0.000000054*10^-18,J}];
physicalConstants = Append[physicalConstants, {"atomic unit of force",
  8.23872336*10^-8,0.00000010*10^-8,N}];
physicalConstants = Append[physicalConstants, {"atomic unit of length",
  0.52917721067*10^-10,0.00000000012*10^-10,m}];
physicalConstants = Append[physicalConstants, {"atomic unit of mag. dipole mom.",
  1.854801999*10^-23,0.000000011*10^-23,J*T^-1}];
physicalConstants = Append[physicalConstants, {"atomic unit of mag. flux density",
  2.350517550*10^5,0.000000014*10^5,T}];
physicalConstants = Append[physicalConstants, {"atomic unit of magnetizability",
  7.8910365886*10^-29,0.0000000090*10^-29,J*T^-2}];
physicalConstants = Append[physicalConstants, {"atomic unit of mass",
  9.10938356*10^-31,0.00000011*10^-31,kg}];
physicalConstants = Append[physicalConstants, {"atomic unit of mom.um",
  1.992851882*10^-24,0.000000024*10^-24,kg*m*s^-1}];
physicalConstants = Append[physicalConstants, {"atomic unit of permittivity",
  1.112650056*10^-10,0,F*m^-1}];
physicalConstants = Append[physicalConstants, {"atomic unit of time",
  2.418884326509*10^-17,0.000000000014*10^-17,s}];
physicalConstants = Append[physicalConstants, {"atomic unit of velocity",
  2.18769126277*10^6,0.00000000050*10^6,m*s^-1}];
physicalConstants = Append[physicalConstants, {"Avogadro constant",
  6.022140857*10^23,0.000000074*10^23,mol^-1}];
physicalConstants = Append[physicalConstants, {"Bohr magneton",
  927.4009994*10^-26,0.0000057*10^-26,J*T^-1}];
physicalConstants = Append[physicalConstants, {"Bohr magneton in eV/T",
  5.7883818012*10^-5,0.0000000026*10^-5,eV*T^-1}];
physicalConstants = Append[physicalConstants, {"Bohr magneton in Hz/T",
  13.996245042*10^9,0.000000086*10^9,Hz*T^-1}];
physicalConstants = Append[physicalConstants, {"Bohr magneton in inverse meters per tesla",
  46.68644814,0.00000029,m^-1*T^-1}];
physicalConstants = Append[physicalConstants, {"Bohr magneton in K/T",
  0.67171405,0.00000039,K*T^-1}];
physicalConstants = Append[physicalConstants, {"Bohr radius",
  0.52917721067*10^-10,0.00000000012*10^-10,m}];
physicalConstants = Append[physicalConstants, {"Boltzmann constant",
  1.38064852*10^-23,0.00000079*10^-23,J*K^-1}];
physicalConstants = Append[physicalConstants, {"Boltzmann constant in eV/K",
  8.6173303*10^-5,0.0000050*10^-5,eV*K^-1}];
physicalConstants = Append[physicalConstants, {"Boltzmann constant in Hz/K",
  2.0836612*10^10,0.0000012*10^10,Hz*K^-1}];
physicalConstants = Append[physicalConstants, {"Boltzmann constant in inverse meters per kelvin",
  69.503457,0.000040,m^-1*K^-1}];
physicalConstants = Append[physicalConstants, {"characteristic impedance of vacuum",
  376.730313461,0,ohm}];
physicalConstants = Append[physicalConstants, {"classical electron radius",
  2.8179403227*10^-15,0.0000000019*10^-15,m}];
physicalConstants = Append[physicalConstants, {"Compton wavelength",
  2.4263102367*10^-12,0.0000000011*10^-12,m}];
physicalConstants = Append[physicalConstants, {"Compton wavelength over 2 pi",
  386.15926764*10^-15,0.00000018*10^-15,m}];
physicalConstants = Append[physicalConstants, {"conductance quantum",
  7.7480917310*10^-5,0.0000000018*10^-5,S}];
physicalConstants = Append[physicalConstants, {"conventional value of Josephson constant",
  483597.9*10^9,0,Hz*V^-1}];
physicalConstants = Append[physicalConstants, {"conventional value of von Klitzing constant",
  25812.807,0,ohm}];
physicalConstants = Append[physicalConstants, {"Cu x unit",
  1.00207697*10^-13,0.00000028*10^-13,m}];
physicalConstants = Append[physicalConstants, {"deuteron-electron mag. mom. ratio",
  -4.664345535*10^-4,0.000000026*10^-4,1}];
physicalConstants = Append[physicalConstants, {"deuteron-electron mass ratio",
  3670.48296785,0.00000013,1}];
physicalConstants = Append[physicalConstants, {"deuteron g factor",
  0.8574382311,0.0000000048,1}];
physicalConstants = Append[physicalConstants, {"deuteron mag. mom.",
  0.4330735040*10^-26,0.0000000036*10^-26,J*T^-1}];
physicalConstants = Append[physicalConstants, {"deuteron mag. mom. to Bohr magneton ratio",
  0.4669754554*10^-3,0.0000000026*10^-3,1}];
physicalConstants = Append[physicalConstants, {"deuteron mag. mom. to nuclear magneton ratio",
  0.8574382311,0.0000000048,1}];
physicalConstants = Append[physicalConstants, {"deuteron mass",
  3.343583719*10^-27,0.000000041*10^-27,kg}];
physicalConstants = Append[physicalConstants, {"deuteron mass energy equivalent",
  3.005063183*10^-10,0.000000037*10^-10,J}];
physicalConstants = Append[physicalConstants, {"deuteron mass energy equivalent in MeV",
  1875.612928,0.000012,MeV}];
physicalConstants = Append[physicalConstants, {"deuteron mass in u",
  2.013553212745,0.000000000040,u}];
physicalConstants = Append[physicalConstants, {"deuteron molar mass",
  2.013553212745*10^-3,0.000000000040*10^-3,kg*mol^-1}];
physicalConstants = Append[physicalConstants, {"deuteron-neutron mag. mom. ratio",
  -0.44820652,0.00000011,1}];
physicalConstants = Append[physicalConstants, {"deuteron-proton mag. mom. ratio",
  0.3070122077,0.0000000015,1}];
physicalConstants = Append[physicalConstants, {"deuteron-proton mass ratio",
  1.99900750087,0.00000000019,1}];
physicalConstants = Append[physicalConstants, {"deuteron rms charge radius",
  2.1413*10^-15,0.0025*10^-15,m}];
physicalConstants = Append[physicalConstants, {"electric constant",
  8.854187817*10^-12,0,F*m^-1}];
physicalConstants = Append[physicalConstants, {"electron charge to mass quotient",
  -1.758820024*10^11,0.000000011*10^11,C*kg^-1}];
physicalConstants = Append[physicalConstants, {"electron-deuteron mag. mom. ratio",
  -2143.923499,0.000012,1}];
physicalConstants = Append[physicalConstants, {"electron-deuteron mass ratio",
  2.724437107484*10^-4,0.000000000096*10^-4,1}];
physicalConstants = Append[physicalConstants, {"electron g factor",
  -2.00231930436182,0.00000000000052,1}];
physicalConstants = Append[physicalConstants, {"electron gyromag. ratio",
  1.760859644*10^11,0.000000011*10^11,s^-1*T^-1}];
physicalConstants = Append[physicalConstants, {"electron gyromag. ratio over 2 pi",
  28024.95164,0.00017,MHz*T^-1}];
physicalConstants = Append[physicalConstants, {"electron-helion mass ratio",
  1.819543074854*10^-4,0.000000000088*10^-4,1}];
physicalConstants = Append[physicalConstants, {"electron mag. mom.",
  -928.4764620*10^-26,0.0000057*10^-26,J*T^-1}];
physicalConstants = Append[physicalConstants, {"electron mag. mom. anomaly",
  1.15965218091*10^-3,0.00000000026*10^-3,1}];
physicalConstants = Append[physicalConstants, {"electron mag. mom. to Bohr magneton ratio",
  -1.00115965218091,0.00000000000026,1}];
physicalConstants = Append[physicalConstants, {"electron mag. mom. to nuclear magneton ratio",
  -1838.28197234,0.00000017,1}];
physicalConstants = Append[physicalConstants, {"electron mass",
  9.10938356*10^-31,0.00000011*10^-31,kg}];
physicalConstants = Append[physicalConstants, {"electron mass energy equivalent",
  8.18710565*10^-14,0.00000010*10^-14,J}];
physicalConstants = Append[physicalConstants, {"electron mass energy equivalent in MeV",
  0.5109989461,0.0000000031,MeV}];
physicalConstants = Append[physicalConstants, {"electron mass in u",
  5.48579909070*10^-4,0.00000000016*10^-4,u}];
physicalConstants = Append[physicalConstants, {"electron molar mass",
  5.48579909070*10^-7,0.00000000016*10^-7,kg*mol^-1}];
physicalConstants = Append[physicalConstants, {"electron-muon mag. mom. ratio",
  206.7669880,0.0000046,1}];
physicalConstants = Append[physicalConstants, {"electron-muon mass ratio",
  4.83633170*10^-3,0.00000011*10^-3,1}];
physicalConstants = Append[physicalConstants, {"electron-neutron mag. mom. ratio",
  960.92050,0.00023,1}];
physicalConstants = Append[physicalConstants, {"electron-neutron mass ratio",
  5.4386734428*10^-4,0.0000000027*10^-4,1}];
physicalConstants = Append[physicalConstants, {"electron-proton mag. mom. ratio",
  -658.2106866,0.0000020,1}];
physicalConstants = Append[physicalConstants, {"electron-proton mass ratio",
  5.44617021352*10^-4,0.00000000052*10^-4,1}];
physicalConstants = Append[physicalConstants, {"electron-tau mass ratio",
  2.87592*10^-4,0.00026*10^-4,1}];
physicalConstants = Append[physicalConstants, {"electron to alpha particle mass ratio",
  1.370933554798*10^-4,0.000000000045*10^-4,1}];
physicalConstants = Append[physicalConstants, {"electron to shielded helion mag. mom. ratio",
  864.058257,0.000010,1}];
physicalConstants = Append[physicalConstants, {"electron to shielded proton mag. mom. ratio",
  -658.2275971,0.0000072,1}];
physicalConstants = Append[physicalConstants, {"electron-triton mass ratio",
  1.819200062203*10^-4,0.000000000084*10^-4,1}];
physicalConstants = Append[physicalConstants, {"electron volt",
  1.6021766208*10^-19,0.0000000098*10^-19,J}];
physicalConstants = Append[physicalConstants, {"electron volt-atomic mass unit relationship",
  1.0735441105*10^-9,0.0000000066*10^-9,u}];
physicalConstants = Append[physicalConstants, {"electron volt-hartree relationship",
  3.674932248*10^-2,0.000000023*10^-2,E_h}];
physicalConstants = Append[physicalConstants, {"electron volt-hertz relationship",
  2.417989262*10^14,0.000000015*10^14,Hz}];
physicalConstants = Append[physicalConstants, {"electron volt-inverse meter relationship",
  8.065544005*10^5,0.000000050*10^5,m^-1}];
physicalConstants = Append[physicalConstants, {"electron volt-joule relationship",
  1.6021766208*10^-19,0.0000000098*10^-19,J}];
physicalConstants = Append[physicalConstants, {"electron volt-kelvin relationship",
  1.16045221*10^4,0.00000067*10^4,K}];
physicalConstants = Append[physicalConstants, {"electron volt-kilogram relationship",
  1.782661907*10^-36,0.000000011*10^-36,kg}];
physicalConstants = Append[physicalConstants, {"elementary charge",
  1.6021766208*10^-19,0.0000000098*10^-19,C}];
physicalConstants = Append[physicalConstants, {"elementary charge over h",
  2.417989262*10^14,0.000000015*10^14,A*J^-1}];
physicalConstants = Append[physicalConstants, {"Faraday constant",
  96485.33289,0.00059,C*mol^-1}];
physicalConstants = Append[physicalConstants, {"Faraday constant for conventional electric current",
  96485.3251,0.0012,C_90*mol^-1}];
physicalConstants = Append[physicalConstants, {"Fermi coupling constant",
  1.1663787*10^-5,0.0000006*10^-5,GeV^-2}];
physicalConstants = Append[physicalConstants, {"fine-structure constant",
  7.2973525664*10^-3,0.0000000017*10^-3,1}];
physicalConstants = Append[physicalConstants, {"first radiation constant",
  3.741771790*10^-16,0.000000046*10^-16,W*m^2}];
physicalConstants = Append[physicalConstants, {"first radiation constant for spectral radiance",
  1.191042953*10^-16,0.000000015*10^-16,W*m^2*sr^-1}];
physicalConstants = Append[physicalConstants, {"hartree-atomic mass unit relationship",
  2.9212623197*10^-8,0.0000000013*10^-8,u}];
physicalConstants = Append[physicalConstants, {"hartree-electron volt relationship",
  27.21138602,0.00000017,eV}];
physicalConstants = Append[physicalConstants, {"Hartree energy",
  4.359744650*10^-18,0.000000054*10^-18,J}];
physicalConstants = Append[physicalConstants, {"Hartree energy in eV",
  27.21138602,0.00000017,eV}];
physicalConstants = Append[physicalConstants, {"hartree-hertz relationship",
  6.579683920711*10^15,0.000000000039*10^15,Hz}];
physicalConstants = Append[physicalConstants, {"hartree-inverse meter relationship",
  2.194746313702*10^7,0.000000000013*10^7,m^-1}];
physicalConstants = Append[physicalConstants, {"hartree-joule relationship",
  4.359744650*10^-18,0.000000054*10^-18,J}];
physicalConstants = Append[physicalConstants, {"hartree-kelvin relationship",
  3.1577513*10^5,0.0000018*10^5,K}];
physicalConstants = Append[physicalConstants, {"hartree-kilogram relationship",
  4.850870129*10^-35,0.000000060*10^-35,kg}];
physicalConstants = Append[physicalConstants, {"helion-electron mass ratio",
  5495.88527922,0.00000027,1}];
physicalConstants = Append[physicalConstants, {"helion g factor",
  -4.255250616,0.000000050,1}];
physicalConstants = Append[physicalConstants, {"helion mag. mom.",
  -1.074617522*10^-26,0.000000014*10^-26,J*T^-1}];
physicalConstants = Append[physicalConstants, {"helion mag. mom. to Bohr magneton ratio",
  -1.158740958*10^-3,0.000000014*10^-3,1}];
physicalConstants = Append[physicalConstants, {"helion mag. mom. to nuclear magneton ratio",
  -2.127625308,0.000000025,1}];
physicalConstants = Append[physicalConstants, {"helion mass",
  5.006412700*10^-27,0.000000062*10^-27,kg}];
physicalConstants = Append[physicalConstants, {"helion mass energy equivalent",
  4.499539341*10^-10,0.000000055*10^-10,J}];
physicalConstants = Append[physicalConstants, {"helion mass energy equivalent in MeV",
  2808.391586,0.000017,MeV}];
physicalConstants = Append[physicalConstants, {"helion mass in u",
  3.01493224673,0.00000000012,u}];
physicalConstants = Append[physicalConstants, {"helion molar mass",
  3.01493224673*10^-3,0.00000000012*10^-3,kg*mol^-1}];
physicalConstants = Append[physicalConstants, {"helion-proton mass ratio",
  2.99315267046,0.00000000029,1}];
physicalConstants = Append[physicalConstants, {"hertz-atomic mass unit relationship",
  4.4398216616*10^-24,0.0000000020*10^-24,u}];
physicalConstants = Append[physicalConstants, {"hertz-electron volt relationship",
  4.135667662*10^-15,0.000000025*10^-15,eV}];
physicalConstants = Append[physicalConstants, {"hertz-hartree relationship",
  1.5198298460088*10^-16,0.0000000000090*10^-16,E_h}];
physicalConstants = Append[physicalConstants, {"hertz-inverse meter relationship",
  3.335640951*10^-9,0,m^-1}];
physicalConstants = Append[physicalConstants, {"hertz-joule relationship",
  6.626070040*10^-34,0.000000081*10^-34,J}];
physicalConstants = Append[physicalConstants, {"hertz-kelvin relationship",
  4.7992447*10^-11,0.0000028*10^-11,K}];
physicalConstants = Append[physicalConstants, {"hertz-kilogram relationship",
  7.372497201*10^-51,0.000000091*10^-51,kg}];
physicalConstants = Append[physicalConstants, {"inverse fine-structure constant",
  137.035999139,0.000000031,1}];
physicalConstants = Append[physicalConstants, {"inverse meter-atomic mass unit relationship",
  1.33102504900*10^-15,0.00000000061*10^-15,u}];
physicalConstants = Append[physicalConstants, {"inverse meter-electron volt relationship",
  1.2398419739*10^-6,0.0000000076*10^-6,eV}];
physicalConstants = Append[physicalConstants, {"inverse meter-hartree relationship",
  4.556335252767*10^-8,0.000000000027*10^-8,E_h}];
physicalConstants = Append[physicalConstants, {"inverse meter-hertz relationship",
  299792458,0,Hz}];
physicalConstants = Append[physicalConstants, {"inverse meter-joule relationship",
  1.986445824*10^-25,0.000000024*10^-25,J}];
physicalConstants = Append[physicalConstants, {"inverse meter-kelvin relationship",
  1.43877736*10^-2,0.00000083*10^-2,K}];
physicalConstants = Append[physicalConstants, {"inverse meter-kilogram relationship",
  2.210219057*10^-42,0.000000027*10^-42,kg}];
physicalConstants = Append[physicalConstants, {"inverse of conductance quantum",
  12906.4037278,0.0000029,ohm}];
physicalConstants = Append[physicalConstants, {"Josephson constant",
  483597.8525*10^9,0.0030*10^9,Hz*V^-1}];
physicalConstants = Append[physicalConstants, {"joule-atomic mass unit relationship",
  6.700535363*10^9,0.000000082*10^9,u}];
physicalConstants = Append[physicalConstants, {"joule-electron volt relationship",
  6.241509126*10^18,0.000000038*10^18,eV}];
physicalConstants = Append[physicalConstants, {"joule-hartree relationship",
  2.293712317*10^17,0.000000028*10^17,E_h}];
physicalConstants = Append[physicalConstants, {"joule-hertz relationship",
  1.509190205*10^33,0.000000019*10^33,Hz}];
physicalConstants = Append[physicalConstants, {"joule-inverse meter relationship",
  5.034116651*10^24,0.000000062*10^24,m^-1}];
physicalConstants = Append[physicalConstants, {"joule-kelvin relationship",
  7.2429731*10^22,0.0000042*10^22,K}];
physicalConstants = Append[physicalConstants, {"joule-kilogram relationship",
  1.112650056*10^-17,0,kg}];
physicalConstants = Append[physicalConstants, {"kelvin-atomic mass unit relationship",
  9.2510842*10^-14,0.0000053*10^-14,u}];
physicalConstants = Append[physicalConstants, {"kelvin-electron volt relationship",
  8.6173303*10^-5,0.0000050*10^-5,eV}];
physicalConstants = Append[physicalConstants, {"kelvin-hartree relationship",
  3.1668105*10^-6,0.0000018*10^-6,E_h}];
physicalConstants = Append[physicalConstants, {"kelvin-hertz relationship",
  2.0836612*10^10,0.0000012*10^10,Hz}];
physicalConstants = Append[physicalConstants, {"kelvin-inverse meter relationship",
  69.503457,0.000040,m^-1}];
physicalConstants = Append[physicalConstants, {"kelvin-joule relationship",
  1.38064852*10^-23,0.00000079*10^-23,J}];
physicalConstants = Append[physicalConstants, {"kelvin-kilogram relationship",
  1.53617865*10^-40,0.00000088*10^-40,kg}];
physicalConstants = Append[physicalConstants, {"kilogram-atomic mass unit relationship",
  6.022140857*10^26,0.000000074*10^26,u}];
physicalConstants = Append[physicalConstants, {"kilogram-electron volt relationship",
  5.609588650*10^35,0.000000034*10^35,eV}];
physicalConstants = Append[physicalConstants, {"kilogram-hartree relationship",
  2.061485823*10^34,0.000000025*10^34,E_h}];
physicalConstants = Append[physicalConstants, {"kilogram-hertz relationship",
  1.356392512*10^50,0.000000017*10^50,Hz}];
physicalConstants = Append[physicalConstants, {"kilogram-inverse meter relationship",
  4.524438411*10^41,0.000000056*10^41,m^-1}];
physicalConstants = Append[physicalConstants, {"kilogram-joule relationship",
  8.987551787*10^16,0,J}];
physicalConstants = Append[physicalConstants, {"kilogram-kelvin relationship",
  6.5096595*10^39,0.0000037*10^39,K}];
physicalConstants = Append[physicalConstants, {"lattice parameter of silicon",
  543.1020504*10^-12,0.0000089*10^-12,m}];
physicalConstants = Append[physicalConstants, {"Loschmidt constant (273.15 K, 100 kPa)",
  2.6516467*10^25,0.0000015*10^25,m^-3}];
physicalConstants = Append[physicalConstants, {"Loschmidt constant (273.15 K, 101.325 kPa)",
  2.6867811*10^25,0.0000015*10^25,m^-3}];
physicalConstants = Append[physicalConstants, {"mag. constant",
  12.566370614*10^-7,0,N*A^-2}];
physicalConstants = Append[physicalConstants, {"mag. flux quantum",
  2.067833831*10^-15,0.000000013*10^-15,Wb}];
physicalConstants = Append[physicalConstants, {"molar gas constant",
  8.3144598,0.0000048,J*mol^-1*K^-1}];
physicalConstants = Append[physicalConstants, {"molar mass constant",
  1*10^-3,0,kg*mol^-1}];
physicalConstants = Append[physicalConstants, {"molar mass of carbon-12",
  12*10^-3,0,kg*mol^-1}];
physicalConstants = Append[physicalConstants, {"molar Planck constant",
  3.9903127110*10^-10,0.0000000018*10^-10,J*s*mol^-1}];
physicalConstants = Append[physicalConstants, {"molar Planck constant times c",
  0.119626565582,0.000000000054,J*m*mol^-1}];
physicalConstants = Append[physicalConstants, {"molar volume of ideal gas (273.15 K, 100 kPa)",
  22.710947*10^-3,0.000013*10^-3,m^3*mol^-1}];
physicalConstants = Append[physicalConstants, {"molar volume of ideal gas (273.15 K, 101.325 kPa)",
  22.413962*10^-3,0.000013*10^-3,m^3*mol^-1}];
physicalConstants = Append[physicalConstants, {"molar volume of silicon",
  12.05883214*10^-6,0.00000061*10^-6,m^3*mol^-1}];
physicalConstants = Append[physicalConstants, {"Mo x unit",
  1.00209952*10^-13,0.00000053*10^-13,m}];
physicalConstants = Append[physicalConstants, {"muon Compton wavelength",
  11.73444111*10^-15,0.00000026*10^-15,m}];
physicalConstants = Append[physicalConstants, {"muon Compton wavelength over 2 pi",
  1.867594308*10^-15,0.000000042*10^-15,m}];
physicalConstants = Append[physicalConstants, {"muon-electron mass ratio",
  206.7682826,0.0000046,1}];
physicalConstants = Append[physicalConstants, {"muon g factor",
  -2.0023318418,0.0000000013,1}];
physicalConstants = Append[physicalConstants, {"muon mag. mom.",
  -4.49044826*10^-26,0.00000010*10^-26,J*T^-1}];
physicalConstants = Append[physicalConstants, {"muon mag. mom. anomaly",
  1.16592089*10^-3,0.00000063*10^-3,1}];
physicalConstants = Append[physicalConstants, {"muon mag. mom. to Bohr magneton ratio",
  -4.84197048*10^-3,0.00000011*10^-3,1}];
physicalConstants = Append[physicalConstants, {"muon mag. mom. to nuclear magneton ratio",
  -8.89059705,0.00000020,1}];
physicalConstants = Append[physicalConstants, {"muon mass",
  1.883531594*10^-28,0.000000048*10^-28,kg}];
physicalConstants = Append[physicalConstants, {"muon mass energy equivalent",
  1.692833774*10^-11,0.000000043*10^-11,J}];
physicalConstants = Append[physicalConstants, {"muon mass energy equivalent in MeV",
  105.6583745,0.0000024,MeV}];
physicalConstants = Append[physicalConstants, {"muon mass in u",
  0.1134289257,0.0000000025,u}];
physicalConstants = Append[physicalConstants, {"muon molar mass",
  0.1134289257*10^-3,0.0000000025*10^-3,kg*mol^-1}];
physicalConstants = Append[physicalConstants, {"muon-neutron mass ratio",
  0.1124545167,0.0000000025,1}];
physicalConstants = Append[physicalConstants, {"muon-proton mag. mom. ratio",
  -3.183345142,0.000000071,1}];
physicalConstants = Append[physicalConstants, {"muon-proton mass ratio",
  0.1126095262,0.0000000025,1}];
physicalConstants = Append[physicalConstants, {"muon-tau mass ratio",
  5.94649*10^-2,0.00054*10^-2,1}];
physicalConstants = Append[physicalConstants, {"natural unit of action",
  1.054571800*10^-34,0.000000013*10^-34,J*s}];
physicalConstants = Append[physicalConstants, {"natural unit of action in eV s",
  6.582119514*10^-16,0.000000040*10^-16,eV*s}];
physicalConstants = Append[physicalConstants, {"natural unit of energy",
  8.18710565*10^-14,0.00000010*10^-14,J}];
physicalConstants = Append[physicalConstants, {"natural unit of energy in MeV",
  0.5109989461,0.0000000031,MeV}];
physicalConstants = Append[physicalConstants, {"natural unit of length",
  386.15926764*10^-15,0.00000018*10^-15,m}];
physicalConstants = Append[physicalConstants, {"natural unit of mass",
  9.10938356*10^-31,0.00000011*10^-31,kg}];
physicalConstants = Append[physicalConstants, {"natural unit of mom.um",
  2.730924488*10^-22,0.000000034*10^-22,kg*m*s^-1}];
physicalConstants = Append[physicalConstants, {"natural unit of mom.um in MeV/c",
  0.5109989461,0.0000000031,MeV/c}];
physicalConstants = Append[physicalConstants, {"natural unit of time",
  1.28808866712*10^-21,0.00000000058*10^-21,s}];
physicalConstants = Append[physicalConstants, {"natural unit of velocity",
  299792458,0,m*s^-1}];
physicalConstants = Append[physicalConstants, {"neutron Compton wavelength",
  1.31959090481*10^-15,0.00000000088*10^-15,m}];
physicalConstants = Append[physicalConstants, {"neutron Compton wavelength over 2 pi",
  0.21001941536*10^-15,0.00000000014*10^-15,m}];
physicalConstants = Append[physicalConstants, {"neutron-electron mag. mom. ratio",
  1.04066882*10^-3,0.00000025*10^-3,1}];
physicalConstants = Append[physicalConstants, {"neutron-electron mass ratio",
  1838.68366158,0.00000090,1}];
physicalConstants = Append[physicalConstants, {"neutron g factor",
  -3.82608545,0.00000090,1}];
physicalConstants = Append[physicalConstants, {"neutron gyromag. ratio",
  1.83247172*10^8,0.00000043*10^8,s^-1*T^-1}];
physicalConstants = Append[physicalConstants, {"neutron gyromag. ratio over 2 pi",
  29.1646933,0.0000069,MHz*T^-1}];
physicalConstants = Append[physicalConstants, {"neutron mag. mom.",
  -0.96623650*10^-26,0.00000023*10^-26,J*T^-1}];
physicalConstants = Append[physicalConstants, {"neutron mag. mom. to Bohr magneton ratio",
  -1.04187563*10^-3,0.00000025*10^-3,1}];
physicalConstants = Append[physicalConstants, {"neutron mag. mom. to nuclear magneton ratio",
  -1.91304273,0.00000045,1}];
physicalConstants = Append[physicalConstants, {"neutron mass",
  1.674927471*10^-27,0.000000021*10^-27,kg}];
physicalConstants = Append[physicalConstants, {"neutron mass energy equivalent",
  1.505349739*10^-10,0.000000019*10^-10,J}];
physicalConstants = Append[physicalConstants, {"neutron mass energy equivalent in MeV",
  939.5654133,0.0000058,MeV}];
physicalConstants = Append[physicalConstants, {"neutron mass in u",
  1.00866491588,0.00000000049,u}];
physicalConstants = Append[physicalConstants, {"neutron molar mass",
  1.00866491588*10^-3,0.00000000049*10^-3,kg*mol^-1}];
physicalConstants = Append[physicalConstants, {"neutron-muon mass ratio",
  8.89248408,0.00000020,1}];
physicalConstants = Append[physicalConstants, {"neutron-proton mag. mom. ratio",
  -0.68497934,0.00000016,1}];
physicalConstants = Append[physicalConstants, {"neutron-proton mass difference",
  2.30557377*10^-30,0.00000085*10^-30,1}];
physicalConstants = Append[physicalConstants, {"neutron-proton mass difference energy equivalent",
  2.07214637*10^-13,0.00000076*10^-13,1}];
physicalConstants = Append[physicalConstants, {"neutron-proton mass difference energy equivalent in MeV",
  1.29333205,0.00000048,1}];
physicalConstants = Append[physicalConstants, {"neutron-proton mass difference in u",
  0.00138844900,0.00000000051,1}];
physicalConstants = Append[physicalConstants, {"neutron-proton mass ratio",
  1.00137841898,0.00000000051,1}];
physicalConstants = Append[physicalConstants, {"neutron-tau mass ratio",
  0.528790,0.000048,1}];
physicalConstants = Append[physicalConstants, {"neutron to shielded proton mag. mom. ratio",
  -0.68499694,0.00000016,1}];
physicalConstants = Append[physicalConstants, {"Newtonian constant of gravitation",
  6.67408*10^-11,0.00031*10^-11,m^3*kg^-1*s^-2}];
physicalConstants = Append[physicalConstants, {"Newtonian constant of gravitation over h-bar c",
  6.70861*10^-39,0.00031*10^-39,(GeV/c^2)^-2}];
physicalConstants = Append[physicalConstants, {"nuclear magneton",
  5.050783699*10^-27,0.000000031*10^-27,J*T^-1}];
physicalConstants = Append[physicalConstants, {"nuclear magneton in eV/T",
  3.1524512550*10^-8,0.0000000015*10^-8,eV*T^-1}];
physicalConstants = Append[physicalConstants, {"nuclear magneton in inverse meters per tesla",
  2.542623432*10^-2,0.000000016*10^-2,m^-1*T^-1}];
physicalConstants = Append[physicalConstants, {"nuclear magneton in K/T",
  3.6582690*10^-4,0.0000021*10^-4,K*T^-1}];
physicalConstants = Append[physicalConstants, {"nuclear magneton in MHz/T",
  7.622593285,0.000000047,MHz*T^-1}];
physicalConstants = Append[physicalConstants, {"Planck constant",
  6.626070040*10^-34,0.000000081*10^-34,J*s}];
physicalConstants = Append[physicalConstants, {"Planck constant in eV s",
  4.135667662*10^-15,0.000000025*10^-15,eV*s}];
physicalConstants = Append[physicalConstants, {"Planck constant over 2 pi",
  1.054571800*10^-34,0.000000013*10^-34,J*s}];
physicalConstants = Append[physicalConstants, {"Planck constant over 2 pi in eV s",
  6.582119514*10^-16,0.000000040*10^-16,eV*s}];
physicalConstants = Append[physicalConstants, {"Planck constant over 2 pi times c in MeV fm",
  197.3269788,0.0000012,MeV*fm}];
physicalConstants = Append[physicalConstants, {"Planck length",
  1.616229*10^-35,0.000038*10^-35,m}];
physicalConstants = Append[physicalConstants, {"Planck mass",
  2.176470*10^-8,0.000051*10^-8,kg}];
physicalConstants = Append[physicalConstants, {"Planck mass energy equivalent in GeV",
  1.220910*10^19,0.000029*10^19,GeV}];
physicalConstants = Append[physicalConstants, {"Planck temperature",
  1.416808*10^32,0.000033*10^32,K}];
physicalConstants = Append[physicalConstants, {"Planck time",
  5.39116*10^-44,0.00013*10^-44,s}];
physicalConstants = Append[physicalConstants, {"proton charge to mass quotient",
  9.578833226*10^7,0.000000059*10^7,C*kg^-1}];
physicalConstants = Append[physicalConstants, {"proton Compton wavelength",
  1.32140985396*10^-15,0.00000000061*10^-15,m}];
physicalConstants = Append[physicalConstants, {"proton Compton wavelength over 2 pi",
  0.210308910109*10^-15,0.000000000097*10^-15,m}];
physicalConstants = Append[physicalConstants, {"proton-electron mass ratio",
  1836.15267389,0.00000017,1}];
physicalConstants = Append[physicalConstants, {"proton g factor",
  5.585694702,0.000000017,1}];
physicalConstants = Append[physicalConstants, {"proton gyromag. ratio",
  2.675221900*10^8,0.000000018*10^8,s^-1*T^-1}];
physicalConstants = Append[physicalConstants, {"proton gyromag. ratio over 2 pi",
  42.57747892,0.00000029,MHz*T^-1}];
physicalConstants = Append[physicalConstants, {"proton mag. mom.",
  1.4106067873*10^-26,0.0000000097*10^-26,J*T^-1}];
physicalConstants = Append[physicalConstants, {"proton mag. mom. to Bohr magneton ratio",
  1.5210322053*10^-3,0.0000000046*10^-3,1}];
physicalConstants = Append[physicalConstants, {"proton mag. mom. to nuclear magneton ratio",
  2.7928473508,0.0000000085,1}];
physicalConstants = Append[physicalConstants, {"proton mag. shielding correction",
  25.691*10^-6,0.011*10^-6,1}];
physicalConstants = Append[physicalConstants, {"proton mass",
  1.672621898*10^-27,0.000000021*10^-27,kg}];
physicalConstants = Append[physicalConstants, {"proton mass energy equivalent",
  1.503277593*10^-10,0.000000018*10^-10,J}];
physicalConstants = Append[physicalConstants, {"proton mass energy equivalent in MeV",
  938.2720813,0.0000058,MeV}];
physicalConstants = Append[physicalConstants, {"proton mass in u",
  1.007276466879,0.000000000091,u}];
physicalConstants = Append[physicalConstants, {"proton molar mass",
  1.007276466879*10^-3,0.000000000091*10^-3,kg*mol^-1}];
physicalConstants = Append[physicalConstants, {"proton-muon mass ratio",
  8.88024338,0.00000020,1}];
physicalConstants = Append[physicalConstants, {"proton-neutron mag. mom. ratio",
  -1.45989805,0.00000034,1}];
physicalConstants = Append[physicalConstants, {"proton-neutron mass ratio",
  0.99862347844,0.00000000051,1}];
physicalConstants = Append[physicalConstants, {"proton rms charge radius",
  0.8751*10^-15,0.0061*10^-15,m}];
physicalConstants = Append[physicalConstants, {"proton-tau mass ratio",
  0.528063,0.000048,1}];
physicalConstants = Append[physicalConstants, {"quantum of circulation",
  3.6369475486*10^-4,0.0000000017*10^-4,m^2*s^-1}];
physicalConstants = Append[physicalConstants, {"quantum of circulation times 2",
  7.2738950972*10^-4,0.0000000033*10^-4,m^2*s^-1}];
physicalConstants = Append[physicalConstants, {"Rydberg constant",
  10973731.568508,0.000065,m^-1}];
physicalConstants = Append[physicalConstants, {"Rydberg constant times c in Hz",
  3.289841960355*10^15,0.000000000019*10^15,Hz}];
physicalConstants = Append[physicalConstants, {"Rydberg constant times hc in eV",
  13.605693009,0.000000084,eV}];
physicalConstants = Append[physicalConstants, {"Rydberg constant times hc in J",
  2.179872325*10^-18,0.000000027*10^-18,J}];
physicalConstants = Append[physicalConstants, {"Sackur-Tetrode constant (1 K, 100 kPa)",
  -1.1517084,0.0000014,1}];
physicalConstants = Append[physicalConstants, {"Sackur-Tetrode constant (1 K, 101.325 kPa)",
  -1.1648714,0.0000014,1}];
physicalConstants = Append[physicalConstants, {"second radiation constant",
  1.43877736*10^-2,0.00000083*10^-2,m*K}];
physicalConstants = Append[physicalConstants, {"shielded helion gyromag. ratio",
  2.037894585*10^8,0.000000027*10^8,s^-1*T^-1}];
physicalConstants = Append[physicalConstants, {"shielded helion gyromag. ratio over 2 pi",
  32.43409966,0.00000043,MHz*T^-1}];
physicalConstants = Append[physicalConstants, {"shielded helion mag. mom.",
  -1.074553080*10^-26,0.000000014*10^-26,J*T^-1}];
physicalConstants = Append[physicalConstants, {"shielded helion mag. mom. to Bohr magneton ratio",
  -1.158671471*10^-3,0.000000014*10^-3,1}];
physicalConstants = Append[physicalConstants, {"shielded helion mag. mom. to nuclear magneton ratio",
  -2.127497720,0.000000025,1}];
physicalConstants = Append[physicalConstants, {"shielded helion to proton mag. mom. ratio",
  -0.7617665603,0.0000000092,1}];
physicalConstants = Append[physicalConstants, {"shielded helion to shielded proton mag. mom. ratio",
  -0.7617861313,0.0000000033,1}];
physicalConstants = Append[physicalConstants, {"shielded proton gyromag. ratio",
  2.675153171*10^8,0.000000033*10^8,s^-1*T^-1}];
physicalConstants = Append[physicalConstants, {"shielded proton gyromag. ratio over 2 pi",
  42.57638507,0.00000053,MHz*T^-1}];
physicalConstants = Append[physicalConstants, {"shielded proton mag. mom.",
  1.410570547*10^-26,0.000000018*10^-26,J*T^-1}];
physicalConstants = Append[physicalConstants, {"shielded proton mag. mom. to Bohr magneton ratio",
  1.520993128*10^-3,0.000000017*10^-3,1}];
physicalConstants = Append[physicalConstants, {"shielded proton mag. mom. to nuclear magneton ratio",
  2.792775600,0.000000030,1}];
physicalConstants = Append[physicalConstants, {"speed of light in vacuum",
  299792458,0,m*s^-1}];
physicalConstants = Append[physicalConstants, {"standard acceleration of gravity",
  9.80665,0,m*s^-2}];
physicalConstants = Append[physicalConstants, {"standard atmosphere",
  101325,0,Pa}];
physicalConstants = Append[physicalConstants, {"standard-state pressure",
  100000,0,Pa}];
physicalConstants = Append[physicalConstants, {"Stefan-Boltzmann constant",
  5.670367*10^-8,0.000013*10^-8,W*m^-2*K^-4}];
physicalConstants = Append[physicalConstants, {"tau Compton wavelength",
  0.697787*10^-15,0.000063*10^-15,m}];
physicalConstants = Append[physicalConstants, {"tau Compton wavelength over 2 pi",
  0.111056*10^-15,0.000010*10^-15,m}];
physicalConstants = Append[physicalConstants, {"tau-electron mass ratio",
  3477.15,0.31,1}];
physicalConstants = Append[physicalConstants, {"tau mass",
  3.16747*10^-27,0.00029*10^-27,kg}];
physicalConstants = Append[physicalConstants, {"tau mass energy equivalent",
  2.84678*10^-10,0.00026*10^-10,J}];
physicalConstants = Append[physicalConstants, {"tau mass energy equivalent in MeV",
  1776.82,0.16,MeV}];
physicalConstants = Append[physicalConstants, {"tau mass in u",
  1.90749,0.00017,u}];
physicalConstants = Append[physicalConstants, {"tau molar mass",
  1.90749*10^-3,0.00017*10^-3,kg*mol^-1}];
physicalConstants = Append[physicalConstants, {"tau-muon mass ratio",
  16.8167,0.0015,1}];
physicalConstants = Append[physicalConstants, {"tau-neutron mass ratio",
  1.89111,0.00017,1}];
physicalConstants = Append[physicalConstants, {"tau-proton mass ratio",
  1.89372,0.00017,1}];
physicalConstants = Append[physicalConstants, {"Thomson cross section",
  0.66524587158*10^-28,0.00000000091*10^-28,m^2}];
physicalConstants = Append[physicalConstants, {"triton-electron mass ratio",
  5496.92153588,0.00000026,1}];
physicalConstants = Append[physicalConstants, {"triton g factor",
  5.957924920,0.000000028,1}];
physicalConstants = Append[physicalConstants, {"triton mag. mom.",
  1.504609503*10^-26,0.000000012*10^-26,J*T^-1}];
physicalConstants = Append[physicalConstants, {"triton mag. mom. to Bohr magneton ratio",
  1.6223936616*10^-3,0.0000000076*10^-3,1}];
physicalConstants = Append[physicalConstants, {"triton mag. mom. to nuclear magneton ratio",
  2.978962460,0.000000014,1}];
physicalConstants = Append[physicalConstants, {"triton mass",
  5.007356665*10^-27,0.000000062*10^-27,kg}];
physicalConstants = Append[physicalConstants, {"triton mass energy equivalent",
  4.500387735*10^-10,0.000000055*10^-10,J}];
physicalConstants = Append[physicalConstants, {"triton mass energy equivalent in MeV",
  2808.921112,0.000017,MeV}];
physicalConstants = Append[physicalConstants, {"triton mass in u",
  3.01550071632,0.00000000011,u}];
physicalConstants = Append[physicalConstants, {"triton molar mass",
  3.01550071632*10^-3,0.00000000011*10^-3,kg*mol^-1}];
physicalConstants = Append[physicalConstants, {"triton-proton mass ratio",
  2.99371703348,0.00000000022,1}];
physicalConstants = Append[physicalConstants, {"unified atomic mass unit",
  1.660539040*10^-27,0.000000020*10^-27,kg}];
physicalConstants = Append[physicalConstants, {"von Klitzing constant",
  25812.8074555,0.0000059,ohm}];
physicalConstants = Append[physicalConstants, {"weak mixing angle",
  0.2223,0.0021,1}];
physicalConstants = Append[physicalConstants, {"Wien frequency displacement law constant",
  5.8789238*10^10,0.0000034*10^10,Hz*K^-1}];
physicalConstants = Append[physicalConstants, {"Wien wavelength displacement law constant",
  2.8977729*10^-3,0.0000017*10^-3,m*K}];
