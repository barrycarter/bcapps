#!/bin/perl

# parses the TGAS files in http://cdn.gea.esac.esa.int/Gaia/tgas_source/csv/

require "/usr/local/lib/bclib.pl";

# array of fields (to avoid getting messed up w/ positions)

my(@fields) = ("hip", "tycho2_id", "solution_id", "source_id", "random_index",
"ref_epoch", "ra", "ra_error", "dec", "dec_error", "parallax",
"parallax_error", "pmra", "pmra_error", "pmdec", "pmdec_error",
"ra_dec_corr", "ra_parallax_corr", "ra_pmra_corr", "ra_pmdec_corr",
"dec_parallax_corr", "dec_pmra_corr", "dec_pmdec_corr",
"parallax_pmra_corr", "parallax_pmdec_corr", "pmra_pmdec_corr",
"astrometric_n_obs_al", "astrometric_n_obs_ac",
"astrometric_n_good_obs_al", "astrometric_n_good_obs_ac",
"astrometric_n_bad_obs_al", "astrometric_n_bad_obs_ac",
"astrometric_delta_q", "astrometric_excess_noise",
"astrometric_excess_noise_sig", "astrometric_primary_flag",
"astrometric_relegation_factor", "astrometric_weight_al",
"astrometric_weight_ac", "astrometric_priors_used",
"matched_observations", "duplicated_source",
"scan_direction_strength_k1", "scan_direction_strength_k2",
"scan_direction_strength_k3", "scan_direction_strength_k4",
"scan_direction_mean_k1", "scan_direction_mean_k2",
"scan_direction_mean_k3", "scan_direction_mean_k4", "phot_g_n_obs",
"phot_g_mean_flux", "phot_g_mean_flux_error", "phot_g_mean_mag",
"phot_variable_flag", "l", "b", "ecl_lon", "ecl_lat");

while (<>) {

  my(@list) = csv($_);

  my(%hash);

  for $i (0..$#fields) {$hash{$fields[$i]} = $list[$i];}

  if ($hash{phot_g_mean_mag} eq "NOT_AVAILABLE") {next;}

  debug("$hash{hip} $hash{ra} $hash{dec} $hash{parallax} $hash{phot_g_mean_mag}");

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

# pm = proper motion
12 pmra
13 pmra_error
14 pmdec
15 pmdec_error

# correlation coefficients
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

parallax is in microarcseconds, so 0.6685584484793923 parallex = 668.558 parsecs or 

query from https://www.aanda.org/articles/aa/full_html/2016/11/aa29512-16/T3.html

[s]elect gaia.source_id, gaia.hip, gaia.phot_g_mean_mag+5*log10(gaia.parallax)-10 as g_mag_abs_gaia, gaia.phot_g_mean_mag+5*log10(hip.plx)-10 as g_mag_abs_hip, hip.b_v from gaiadr1.tgas_source as gaia inner join public.hipparcos_newreduction as hip on gaia.hip = hip.hip where gaia.parallax/gaia.parallax_error >= 5 and hip.plx/hip.e_plx >= 5 and hip.e_b_v > 0.0 and hip.e_b_v <= 0.05 and 2.5/log(10)*gaia.phot_g_mean_flux_error/gaia.phot_g_mean_flux <= 0.05 



=cut
