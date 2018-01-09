#!/bin/perl

# parses the TGAS files in http://cdn.gea.esac.esa.int/Gaia/tgas_source/csv/

require "/usr/local/lib/bclib.pl";

while (<>) {

  my(@list) = csv($_);

  # I want magnitude, parallax and ra/dec coords (TODO: are galactic coords better?)

  my($mag, $par, $ra, $dec) = @list[53,10,6,8];

  debug("MAG: $mag");
}

=item comment

The fields are:

0 hip
1 tycho2_id
2 solution_id
3 source_id
4 random_index
5 ref_epoch
6 ra
7 ra_error
8 dec
9 dec_error
10 parallax
11 parallax_error
12 pmra
13 pmra_error
14 pmdec
15 pmdec_error
16 ra_dec_corr
17 ra_parallax_corr
18 ra_pmra_corr
19 ra_pmdec_corr
20 dec_parallax_corr
21 dec_pmra_corr
22 dec_pmdec_corr
23 parallax_pmra_corr
24 parallax_pmdec_corr
25 pmra_pmdec_corr
26 astrometric_n_obs_al
27 astrometric_n_obs_ac
28 astrometric_n_good_obs_al
29 astrometric_n_good_obs_ac
30 astrometric_n_bad_obs_al
31 astrometric_n_bad_obs_ac
32 astrometric_delta_q
33 astrometric_excess_noise
34 astrometric_excess_noise_sig
35 astrometric_primary_flag
36 astrometric_relegation_factor
37 astrometric_weight_al
38 astrometric_weight_ac
39 astrometric_priors_used
40 matched_observations
41 duplicated_source
42 scan_direction_strength_k1
43 scan_direction_strength_k2
44 scan_direction_strength_k3
45 scan_direction_strength_k4
46 scan_direction_mean_k1
47 scan_direction_mean_k2
48 scan_direction_mean_k3
49 scan_direction_mean_k4
50 phot_g_n_obs
51 phot_g_mean_flux
52 phot_g_mean_flux_error
53 phot_g_mean_mag
54 phot_variable_flag
55 l
56 b
57 ecl_lon
58 ecl_lat

=cut
