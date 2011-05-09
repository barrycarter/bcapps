<?php
/*
Plugin Name: Easy Timer
Plugin URI: http://www.kleor-editions.com/easy-timer
Description: Allows you to easily display a count down/up timer, the time or the current date on your website, and to schedule an automatic content modification.
Version: 2.5.4
Author: Kleor
Author URI: http://www.kleor-editions.com
Text Domain: easy-timer
License: GPL2
*/

/* 
Copyright 2010 Kleor Editions (http://www.kleor-editions.com)

This program is a free software. You can redistribute it and/or 
modify it under the terms of the GNU General Public License as 
published by the Free Software Foundation, either version 2 of 
the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, 
but without any warranty, without even the implied warranty of 
merchantability or fitness for a particular purpose. See the 
GNU General Public License for more details.
*/


define('EASY_TIMER_URL', plugin_dir_url(__FILE__));

load_plugin_textdomain('easy-timer', false, 'easy-timer/languages');

function install_easy_timer() { include_once dirname(__FILE__).'/install.php'; }

register_activation_hook(__FILE__, 'install_easy_timer');

$easy_timer_options = get_option('easy_timer');

$easy_timer_js_attribute = 'id';
if (stristr($_SERVER['HTTP_USER_AGENT'], 'MSIE 9')) { $easy_timer_js_attribute = 'title'; $easy_timer_js_extension = '-ie9'; }

if (is_admin()) { include_once dirname(__FILE__).'/admin.php'; }

$have_relative_counter = array();

if (!function_exists('adodb_mktime')) { include_once 'adodb-time.php'; }


function extract_offset($offset) {
$offset = strtolower($offset); switch ($offset) {
case '': case 'local': $offset = 3600*get_option('gmt_offset'); break;
default: $offset = 36*(round(100*str_replace(',', '.', $offset))); }
return $offset; }


function extract_timestamp($offset) {
if (function_exists('date_default_timezone_set')) { date_default_timezone_set('UTC'); }
return time() + extract_offset($offset); }


function timer($S) {
if ($S < 0) { $S = 0; }
$D = floor($S/86400);
$H = floor($S/3600);
$M = floor($S/60);
$h = $H - 24*$D;
$m = $M - 60*$H;
$s = $S - 60*$M;

$string0day = '';
$string0hour = '';
$string0minute = '';
$string0second = ' '.__('0 second', 'easy-timer');
$string1day = ' '.__('1 day', 'easy-timer');
$string1hour = ' '.__('1 hour', 'easy-timer');
$string1minute = ' '.__('1 minute', 'easy-timer');
$string1second = ' '.__('1 second', 'easy-timer');
$stringNdays = ' [N] '.__('days', 'easy-timer');
$stringNhours = ' [N] '.__('hours', 'easy-timer');
$stringNminutes = ' [N] '.__('minutes', 'easy-timer');
$stringNseconds = ' [N] '.__('seconds', 'easy-timer');

$stringD = $string0day;
$stringH = $string0hour;
$stringM = $string0minute;
$stringS = $string0second;
$stringh = $string0hour;
$stringm = $string0minute;
$strings = $string0second;

if ($D == 1) { $stringD = $string1day; } elseif ($D > 1) { $stringD = str_replace('[N]', $D, $stringNdays); }
if ($H == 1) { $stringH = $string1hour; } elseif ($H > 1) { $stringH = str_replace('[N]', $H, $stringNhours); }
if ($M == 1) { $stringM = $string1minute; } elseif ($M > 1) { $stringM = str_replace('[N]', $M, $stringNminutes); }
if ($S == 1) { $stringS = $string1second; } elseif ($S > 1) { $stringS = str_replace('[N]', $S, $stringNseconds); }
if ($h == 1) { $stringh = $string1hour; } elseif ($h > 1) { $stringh = str_replace('[N]', $h, $stringNhours); }
if ($m == 1) { $stringm = $string1minute; } elseif ($m > 1) { $stringm = str_replace('[N]', $m, $stringNminutes); }
if ($s == 1) { $strings = $string1second; } elseif ($s > 1) { $strings = str_replace('[N]', $s, $stringNseconds); }

if ($S >= 86400) {
$stringDhms = $stringD.$stringh.$stringm.$strings;
$stringDhm = $stringD.$stringh.$stringm;
$stringDh = $stringD.$stringh;
$stringHms = $stringH.$stringm.$strings;
$stringHm = $stringH.$stringm;
$stringMs = $stringM.$strings; }

if (($S >= 3600) && ($S < 86400)) {
$stringDhms = $stringH.$stringm.$strings;
$stringDhm = $stringH.$stringm;
$stringDh = $stringH;
$stringD = $stringH;
$stringHms = $stringH.$stringm.$strings;
$stringHm = $stringH.$stringm;
$stringMs = $stringM.$strings; }

if (($S >= 60) && ($S < 3600)) {
$stringDhms = $stringM.$strings;
$stringDhm = $stringM;
$stringDh = $stringM;
$stringD = $stringM;
$stringHms = $stringM.$strings;
$stringHm = $stringM;
$stringH = $stringM;
$stringMs = $stringM.$strings; }

if ($S < 60) {
$stringDhms = $stringS;
$stringDhm = $stringS;
$stringDh = $stringS;
$stringD = $stringS;
$stringHms = $stringS;
$stringHm = $stringS;
$stringH = $stringS;
$stringMs = $stringS;
$stringM = $stringS; }

$stringhms = $stringh.$stringm.$strings;
$stringhm = $stringh.$stringm;
$stringms = $stringm.$strings;

$timer = array(
'Dhms' => trim($stringDhms),
'Dhm' => trim($stringDhm),
'Dh' => trim($stringDh),
'D' => trim($stringD),
'Hms' => trim($stringHms),
'Hm' => trim($stringHm),
'H' => trim($stringH),
'Ms' => trim($stringMs),
'M' => trim($stringM),
'S' => trim($stringS),
'hms' => trim($stringhms),
'hm' => trim($stringhm),
'h' => trim($stringh),
'ms' => trim($stringms),
'm' => trim($stringm),
's' => trim($strings));

return $timer; }


function timer_replace($S, $T, $prefix, $way, $content) {
global $easy_timer_js_attribute, $easy_timer_options;
$timer = timer($S);

$content = str_replace('['.$prefix.'timer]', '['.$prefix.$easy_timer_options['default_timer_prefix'].'timer]', $content);
$content = str_replace('['.$prefix.'dhmstimer]', '<span class="dhmscount'.$way.'" '.$easy_timer_js_attribute.'="t'.mt_rand(10000000, 99999999).'-'.$T.'">'.$timer['Dhms'].'</span>', $content);
$content = str_replace('['.$prefix.'dhmtimer]', '<span class="dhmcount'.$way.'" '.$easy_timer_js_attribute.'="t'.mt_rand(10000000, 99999999).'-'.$T.'">'.$timer['Dhm'].'</span>', $content);
$content = str_replace('['.$prefix.'dhtimer]', '<span class="dhcount'.$way.'" '.$easy_timer_js_attribute.'="t'.mt_rand(10000000, 99999999).'-'.$T.'">'.$timer['Dh'].'</span>', $content);
$content = str_replace('['.$prefix.'dtimer]', '<span class="dcount'.$way.'" '.$easy_timer_js_attribute.'="t'.mt_rand(10000000, 99999999).'-'.$T.'">'.$timer['D'].'</span>', $content);
$content = str_replace('['.$prefix.'hmstimer]', '<span class="hmscount'.$way.'" '.$easy_timer_js_attribute.'="t'.mt_rand(10000000, 99999999).'-'.$T.'">'.$timer['Hms'].'</span>', $content);
$content = str_replace('['.$prefix.'hmtimer]', '<span class="hmcount'.$way.'" '.$easy_timer_js_attribute.'="t'.mt_rand(10000000, 99999999).'-'.$T.'">'.$timer['Hm'].'</span>', $content);
$content = str_replace('['.$prefix.'htimer]', '<span class="hcount'.$way.'" '.$easy_timer_js_attribute.'="t'.mt_rand(10000000, 99999999).'-'.$T.'">'.$timer['H'].'</span>', $content);
$content = str_replace('['.$prefix.'mstimer]', '<span class="mscount'.$way.'" '.$easy_timer_js_attribute.'="t'.mt_rand(10000000, 99999999).'-'.$T.'">'.$timer['Ms'].'</span>', $content);
$content = str_replace('['.$prefix.'mtimer]', '<span class="mcount'.$way.'" '.$easy_timer_js_attribute.'="t'.mt_rand(10000000, 99999999).'-'.$T.'">'.$timer['M'].'</span>', $content);
$content = str_replace('['.$prefix.'stimer]', '<span class="scount'.$way.'" '.$easy_timer_js_attribute.'="t'.mt_rand(10000000, 99999999).'-'.$T.'">'.$timer['S'].'</span>', $content);

$content = str_replace('['.$prefix.'rtimer]', '['.$prefix.$easy_timer_options['default_timer_prefix'].'rtimer]', $content);
$content = str_replace('['.$prefix.'dhmsrtimer]', '<span class="dhmscount'.$way.'" '.$easy_timer_js_attribute.'="t'.mt_rand(10000000, 99999999).'-'.$T.'">'.$timer['Dhms'].'</span>', $content);
$content = str_replace('['.$prefix.'dhmrtimer]', '<span class="dhmcount'.$way.'" '.$easy_timer_js_attribute.'="t'.mt_rand(10000000, 99999999).'-'.$T.'">'.$timer['Dhm'].'</span>', $content);
$content = str_replace('['.$prefix.'dhrtimer]', '<span class="dhcount'.$way.'" '.$easy_timer_js_attribute.'="t'.mt_rand(10000000, 99999999).'-'.$T.'">'.$timer['Dh'].'</span>', $content);
$content = str_replace('['.$prefix.'drtimer]', '<span class="dcount'.$way.'" '.$easy_timer_js_attribute.'="t'.mt_rand(10000000, 99999999).'-'.$T.'">'.$timer['D'].'</span>', $content);
$content = str_replace('['.$prefix.'hmsrtimer]', '<span class="hmsrcount'.$way.'" '.$easy_timer_js_attribute.'="t'.mt_rand(10000000, 99999999).'-'.$T.'">'.$timer['hms'].'</span>', $content);
$content = str_replace('['.$prefix.'hmrtimer]', '<span class="hmrcount'.$way.'" '.$easy_timer_js_attribute.'="t'.mt_rand(10000000, 99999999).'-'.$T.'">'.$timer['hm'].'</span>', $content);
$content = str_replace('['.$prefix.'hrtimer]', '<span class="hrcount'.$way.'" '.$easy_timer_js_attribute.'="t'.mt_rand(10000000, 99999999).'-'.$T.'">'.$timer['h'].'</span>', $content);
$content = str_replace('['.$prefix.'msrtimer]', '<span class="msrcount'.$way.'" '.$easy_timer_js_attribute.'="t'.mt_rand(10000000, 99999999).'-'.$T.'">'.$timer['ms'].'</span>', $content);
$content = str_replace('['.$prefix.'mrtimer]', '<span class="mrcount'.$way.'" '.$easy_timer_js_attribute.'="t'.mt_rand(10000000, 99999999).'-'.$T.'">'.$timer['m'].'</span>', $content);
$content = str_replace('['.$prefix.'srtimer]', '<span class="srcount'.$way.'" '.$easy_timer_js_attribute.'="t'.mt_rand(10000000, 99999999).'-'.$T.'">'.$timer['s'].'</span>', $content);

return $content; }


function counter($atts, $content) {
global $easy_timer_options, $post;
$id = (int) $post->ID;
if (function_exists('date_default_timezone_set')) { date_default_timezone_set('UTC'); }
extract(shortcode_atts(array('date' => '', 'offset' => '', 'way' => '', 'delimiter' => ''), $atts));
if ($way != 'down') { $way = 'up'; }
if ($delimiter == 'before') { $delimiter = '[before]'; } else { $delimiter = '[after]'; }

if ((substr($date, 0, 1) == '-') || (strstr($date, '//-')) || (strstr($date, '+'))) {
if (!isset($_COOKIE['first-visit-'.$id])) { global $have_relative_counter; $have_relative_counter[$id] = $id; } }

if ($delimiter == '[after]') { $date = '0//'.$date; } else { $date = $date.'//0'; }
$date = explode('//', $date);
if ($delimiter == '[before]') { $date = array_reverse($date); }
$n = count($date);

$time = time();
$S = array(0); $T = array($time);
$is_positive = array(false);
$is_negative = array(false);
$is_relative = array(false);

for ($i = 1; $i < $n; $i++) {
	if (substr($date[$i], 0, 1) == '+') { $is_positive[$i] = true; }
	if (substr($date[$i], 0, 1) == '-') { $is_negative[$i] = true; }
	$is_relative[$i] = (($is_positive[$i]) || ($is_negative[$i]));
	$date[$i] = preg_split('#[^0-9]#', $date[$i]);
	$m = count($date[$i]);
	for ($j = 0; $j < $m; $j++) { $date[$i][$j] = (int) $date[$i][$j]; }
	
	if ($is_relative[$i]) {
	if (isset($_COOKIE['first-visit-'.$id])) { $first_visit_time = $_COOKIE['first-visit-'.$id]; }
	else { $first_visit_time = $time; } 
	$S[$i] = 86400*$date[$i][1] + 3600*$date[$i][2] + 60*$date[$i][3] + $date[$i][4];
	if ($is_positive[$i]) { $S[$i] = $time - $first_visit_time - $S[$i]; }
	if ($is_negative[$i]) { $S[$i] = $time - $first_visit_time + $S[$i]; }
	$T[$i] = $time - $S[$i]; }
	
	else {
	switch ($m) {
	case 0: case 1: $S[$i] = $date[$i][0]; $T[$i] = $time - $S[$i]; break;
	case 2: $S[$i] = 60*$date[$i][0] + $date[$i][1]; $T[$i] = $time - $S[$i]; break;
	default:
	$T[$i] = adodb_mktime($date[$i][3], $date[$i][4], $date[$i][5], $date[$i][1], $date[$i][2], $date[$i][0]) - extract_offset($offset);
	$S[$i] = $time - $T[$i]; } }
}

$i = 0; while (($i < $n) && ($S[$i] >= 0)) { $k = $i; $i = $i + 1; }
if ($i == $n) { $i = $n - 1; }

$content = do_shortcode($content);
if (!strstr($content, $delimiter)) { $content = $content.$delimiter; }
$content = explode($delimiter, $content);
if ($delimiter == '[before]') { $content = array_reverse($content); }

if (($easy_timer_options['javascript_enabled'] == 'yes') && (strstr($content[$k], 'timer]'))) {
add_action('wp_footer', 'easy_timer_lang_js');
add_action('wp_footer', 'easy_timer_js'); }

if ($way == 'up') {
$content[$k] = timer_replace($S[$k], $T[$k], '', 'up', $content[$k]);
$content[$k] = timer_replace($S[1], $T[1], 'total-', 'up', $content[$k]); }
if ($way == 'down') {
$content[$k] = timer_replace(-$S[$i], $T[$i], '', 'down', $content[$k]);
$content[$k] = timer_replace(-$S[$n - 1], $T[$n - 1], 'total-', 'down', $content[$k]); }

$content[$k] = timer_replace($S[$k], $T[$k], 'elapsed-', 'up', $content[$k]);
$content[$k] = timer_replace($S[1], $T[1], 'total-elapsed-', 'up', $content[$k]);
$content[$k] = timer_replace(-$S[$i], $T[$i], 'remaining-', 'down', $content[$k]);
$content[$k] = timer_replace(-$S[$n - 1], $T[$n - 1], 'total-remaining-', 'down', $content[$k]);

return $content[$k]; }

add_shortcode('counter', 'counter');
add_shortcode('counter0', 'counter');
add_shortcode('counter1', 'counter');
add_shortcode('counter2', 'counter');
add_shortcode('counter3', 'counter');
add_shortcode('counter4', 'counter');
add_shortcode('counter5', 'counter');
add_shortcode('counter6', 'counter');
add_shortcode('counter7', 'counter');
add_shortcode('counter8', 'counter');
add_shortcode('counter9', 'counter');
add_shortcode('counter10', 'counter');


function countdown($atts, $content) {
if ($atts['way'] != 'up') { $atts['way'] = 'down'; }
if ($atts['delimiter'] != 'before') { $atts['delimiter'] = 'after'; }
return counter($atts, $content); }

add_shortcode('countdown', 'countdown');
add_shortcode('countdown0', 'countdown');
add_shortcode('countdown1', 'countdown');
add_shortcode('countdown2', 'countdown');
add_shortcode('countdown3', 'countdown');
add_shortcode('countdown4', 'countdown');
add_shortcode('countdown5', 'countdown');
add_shortcode('countdown6', 'countdown');
add_shortcode('countdown7', 'countdown');
add_shortcode('countdown8', 'countdown');
add_shortcode('countdown9', 'countdown');
add_shortcode('countdown10', 'countdown');


function countup($atts, $content) {
if ($atts['way'] != 'down') { $atts['way'] = 'up'; }
if ($atts['delimiter'] != 'after') { $atts['delimiter'] = 'before'; }
return counter($atts, $content); }

add_shortcode('countup', 'countup');
add_shortcode('countup0', 'countup');
add_shortcode('countup1', 'countup');
add_shortcode('countup2', 'countup');
add_shortcode('countup3', 'countup');
add_shortcode('countup4', 'countup');
add_shortcode('countup5', 'countup');
add_shortcode('countup6', 'countup');
add_shortcode('countup7', 'countup');
add_shortcode('countup8', 'countup');
add_shortcode('countup9', 'countup');
add_shortcode('countup10', 'countup');


function clock($atts) {
global $easy_timer_js_attribute, $easy_timer_options;
if (function_exists('date_default_timezone_set')) { date_default_timezone_set('UTC'); }
if ($easy_timer_options['javascript_enabled'] == 'yes') { add_action('wp_footer', 'easy_timer_js'); }
extract(shortcode_atts(array('form' => '', 'offset' => ''), $atts));
$offset = strtolower($offset); switch ($offset) {
case '': $offset = 1*get_option('gmt_offset'); break;
case 'local': break;
default: $offset = (round(100*str_replace(',', '.', $offset)))/100; }
$T = extract_timestamp($offset);

$form = strtolower($form); switch ($form) {
case 'hms': $clock = date('H:i:s', $T); break;
default: $form = 'hm'; $clock = date('H:i', $T); }

if (is_numeric($offset)) { return '<span class="'.$form.'clock" '.$easy_timer_js_attribute.'="t'.mt_rand(10000000, 99999999).'-'.$offset.'">'.$clock.'</span>'; }
else { return '<span class="local'.$form.'clock">'.$clock.'</span>'; } }

add_shortcode('clock', 'clock');


function year($atts) {
global $easy_timer_options;
if (function_exists('date_default_timezone_set')) { date_default_timezone_set('UTC'); }
extract(shortcode_atts(array('form' => '', 'offset' => ''), $atts));
$T = extract_timestamp($offset);

switch ($form) {
case '2': $year = date('y', $T); break;
default: $form = '4'; $year = date('Y', $T); }

if (strtolower($offset) != 'local') { return $year; }
else {
if ($easy_timer_options['javascript_enabled'] == 'yes') { add_action('wp_footer', 'easy_timer_js'); }
return '<span class="local'.$form.'year">'.$year.'</span>'; } }

add_shortcode('year', 'year');


function isoyear($atts) {
global $easy_timer_options;
if (function_exists('date_default_timezone_set')) { date_default_timezone_set('UTC'); }
extract(shortcode_atts(array('offset' => ''), $atts));
$T = extract_timestamp($offset);
$isoyear = date('o', $T);
if (strtolower($offset) != 'local') { return $isoyear; }
else {
if ($easy_timer_options['javascript_enabled'] == 'yes') { add_action('wp_footer', 'easy_timer_js'); }
return '<span class="localisoyear">'.$isoyear.'</span>'; } }

add_shortcode('isoyear', 'isoyear');


function yearweek($atts) {
global $easy_timer_options;
if (function_exists('date_default_timezone_set')) { date_default_timezone_set('UTC'); }
extract(shortcode_atts(array('offset' => ''), $atts));
$T = extract_timestamp($offset);
$yearweek = date('W', $T);
if (strtolower($offset) != 'local') { return $yearweek; }
else {
if ($easy_timer_options['javascript_enabled'] == 'yes') { add_action('wp_footer', 'easy_timer_js'); }
return '<span class="localyearweek">'.$yearweek.'</span>'; } }

add_shortcode('yearweek', 'yearweek');


function yearday($atts) {
global $easy_timer_options;
if (function_exists('date_default_timezone_set')) { date_default_timezone_set('UTC'); }
extract(shortcode_atts(array('offset' => ''), $atts));
$T = extract_timestamp($offset);
$yearday = date('z', $T) + 1;
if (strtolower($offset) != 'local') { return $yearday; }
else {
if ($easy_timer_options['javascript_enabled'] == 'yes') { add_action('wp_footer', 'easy_timer_js'); }
return '<span class="localyearday">'.$yearday.'</span>'; } }

add_shortcode('yearday', 'yearday');


function month($atts) {
global $easy_timer_options;
if (function_exists('date_default_timezone_set')) { date_default_timezone_set('UTC'); }
extract(shortcode_atts(array('form' => '', 'offset' => ''), $atts));
$T = extract_timestamp($offset);
$n = date('n', $T);

$form = strtolower($form); switch ($form) {
case '1': $month = $n; break;
case '2': $month = date('m', $T); break;
case 'lower': case 'upper': break;
default: $form = ''; }

if (($form == '') || ($form == 'lower') || ($form == 'upper')) {
$stringmonth = array(
0 => __('DECEMBER', 'easy-timer'),
1 => __('JANUARY', 'easy-timer'),
2 => __('FEBRUARY', 'easy-timer'),
3 => __('MARCH', 'easy-timer'),
4 => __('APRIL', 'easy-timer'),
5 => __('MAY', 'easy-timer'),
6 => __('JUNE', 'easy-timer'),
7 => __('JULY', 'easy-timer'),
8 => __('AUGUST', 'easy-timer'),
9 => __('SEPTEMBER', 'easy-timer'),
10 => __('OCTOBER', 'easy-timer'),
11 => __('NOVEMBER', 'easy-timer'),
12 => __('DECEMBER', 'easy-timer')); }

if ($form == '') { $month = ucfirst(strtolower($stringmonth[$n])); }
elseif ($form == 'lower') { $month = strtolower($stringmonth[$n]); }
elseif ($form == 'upper') { $month = $stringmonth[$n]; }

if (strtolower($offset) != 'local') { return $month; }
else {
if ($easy_timer_options['javascript_enabled'] == 'yes') {
if (($form == '') || ($form == 'lower') || ($form == 'upper')) { add_action('wp_footer', 'easy_timer_lang_js'); }
add_action('wp_footer', 'easy_timer_js'); }
return '<span class="local'.$form.'month">'.$month.'</span>'; } }

add_shortcode('month', 'month');


function monthday($atts) {
global $easy_timer_options;
if (function_exists('date_default_timezone_set')) { date_default_timezone_set('UTC'); }
extract(shortcode_atts(array('form' => '', 'offset' => ''), $atts));
$T = extract_timestamp($offset);

switch ($form) {
case '2': $monthday = date('d', $T); break;
default: $form = '1'; $monthday = date('j', $T); }

if (strtolower($offset) != 'local') { return $monthday; }
else {
if ($easy_timer_options['javascript_enabled'] == 'yes') { add_action('wp_footer', 'easy_timer_js'); }
return '<span class="local'.$form.'monthday">'.$monthday.'</span>'; } }

add_shortcode('monthday', 'monthday');


function weekday($atts) {
global $easy_timer_options;
if (function_exists('date_default_timezone_set')) { date_default_timezone_set('UTC'); }
extract(shortcode_atts(array('form' => '', 'offset' => ''), $atts));
$T = extract_timestamp($offset);
$w = date('w', $T);

$form = strtolower($form); switch ($form) {
case 'lower': case 'upper': break;
default: $form = ''; }

$stringweekday = array(
0 => __('SUNDAY', 'easy-timer'),
1 => __('MONDAY', 'easy-timer'),
2 => __('TUESDAY', 'easy-timer'),
3 => __('WEDNESDAY', 'easy-timer'),
4 => __('THURSDAY', 'easy-timer'),
5 => __('FRIDAY', 'easy-timer'),
6 => __('SATURDAY', 'easy-timer'),
7 => __('SUNDAY', 'easy-timer'));

if ($form == '') { $weekday = ucfirst(strtolower($stringweekday[$w])); }
elseif ($form == 'lower') { $weekday = strtolower($stringweekday[$w]); }
elseif ($form == 'upper') { $weekday = $stringweekday[$w]; }

if (strtolower($offset) != 'local') { return $weekday; }
else {
if ($easy_timer_options['javascript_enabled'] == 'yes') {
add_action('wp_footer', 'easy_timer_lang_js');
add_action('wp_footer', 'easy_timer_js'); }
return '<span class="local'.$form.'weekday">'.$weekday.'</span>'; } }

add_shortcode('weekday', 'weekday');


function timezone($atts) {
global $easy_timer_options;
extract(shortcode_atts(array('offset' => ''), $atts));
$offset = strtolower($offset); switch ($offset) {
case '': $offset = 1*get_option('gmt_offset'); break;
case 'local': break;
default: $offset = (round(100*str_replace(',', '.', $offset)))/100; }

if (is_numeric($offset)) {
if ($offset == 0) { $timezone = 'UTC'; }
elseif ($offset > 0) { $timezone = 'UTC+'.$offset; }
elseif ($offset < 0) { $timezone = 'UTC'.$offset; }
return $timezone; }

else {
if ($easy_timer_options['javascript_enabled'] == 'yes') { add_action('wp_footer', 'easy_timer_js'); }
return '<span class="localtimezone">UTC</span>'; } }

add_shortcode('timezone', 'timezone');


function easy_timer_js() {
global $easy_timer_js_extension; ?>
<script type="text/javascript" src="<?php echo EASY_TIMER_URL; ?>easy-timer<?php echo $easy_timer_js_extension; ?>.js?ver=2.5.4"></script>
<?php }


function easy_timer_lang_js() { ?>
<script type="text/javascript">
var string0day = '';
var string0hour = '';
var string0minute = '';
var string0second = ' <?php _e('0 second', 'easy-timer'); ?>';
var string1day = ' <?php _e('1 day', 'easy-timer'); ?>';
var string1hour = ' <?php _e('1 hour', 'easy-timer'); ?>';
var string1minute = ' <?php _e('1 minute', 'easy-timer'); ?>';
var string1second = ' <?php _e('1 second', 'easy-timer'); ?>';
var stringNdays = ' [N] <?php _e('days', 'easy-timer'); ?>';
var stringNhours = ' [N] <?php _e('hours', 'easy-timer'); ?>';
var stringNminutes = ' [N] <?php _e('minutes', 'easy-timer'); ?>';
var stringNseconds = ' [N] <?php _e('seconds', 'easy-timer'); ?>';

var stringmonth = new Array(13);
stringmonth[0] = '<?php _e('DECEMBER', 'easy-timer'); ?>';
stringmonth[1] = '<?php _e('JANUARY', 'easy-timer'); ?>';
stringmonth[2] = '<?php _e('FEBRUARY', 'easy-timer'); ?>';
stringmonth[3] = '<?php _e('MARCH', 'easy-timer'); ?>';
stringmonth[4] = '<?php _e('APRIL', 'easy-timer'); ?>';
stringmonth[5] = '<?php _e('MAY', 'easy-timer'); ?>';
stringmonth[6] = '<?php _e('JUNE', 'easy-timer'); ?>';
stringmonth[7] = '<?php _e('JULY', 'easy-timer'); ?>';
stringmonth[8] = '<?php _e('AUGUST', 'easy-timer'); ?>';
stringmonth[9] = '<?php _e('SEPTEMBER', 'easy-timer'); ?>';
stringmonth[10] = '<?php _e('OCTOBER', 'easy-timer'); ?>';
stringmonth[11] = '<?php _e('NOVEMBER', 'easy-timer'); ?>';
stringmonth[12] = '<?php _e('DECEMBER', 'easy-timer'); ?>';

var stringweekday = new Array(8);
stringweekday[0] = '<?php _e('SUNDAY', 'easy-timer'); ?>';
stringweekday[1] = '<?php _e('MONDAY', 'easy-timer'); ?>';
stringweekday[2] = '<?php _e('TUESDAY', 'easy-timer'); ?>';
stringweekday[3] = '<?php _e('WEDNESDAY', 'easy-timer'); ?>';
stringweekday[4] = '<?php _e('THURSDAY', 'easy-timer'); ?>';
stringweekday[5] = '<?php _e('FRIDAY', 'easy-timer'); ?>';
stringweekday[6] = '<?php _e('SATURDAY', 'easy-timer'); ?>';
stringweekday[7] = '<?php _e('SUNDAY', 'easy-timer'); ?>';
</script>
<?php }


function easy_timer_cookies_js() {
global $easy_timer_options, $have_relative_counter;
if (function_exists('date_default_timezone_set')) { date_default_timezone_set('UTC'); }
$T = time();
$U = $T + 86400*$easy_timer_options['cookies_lifetime'];
$expiration_date = date('D', $U).', '.date('d', $U).' '.date('M', $U).' '.date('Y', $U).' '.date('H:i:s', $U).' UTC';
if (!empty($have_relative_counter)) { echo '<script type="text/javascript">'."\n"; }
foreach ($have_relative_counter as $id) { echo 'document.cookie="first-visit-'.$id.'='.$T.'; expires='.$expiration_date.'";'."\n"; }
if (!empty($have_relative_counter)) { echo '</script>'."\n"; } }

if ($easy_timer_options['javascript_enabled'] == 'yes') { add_action('wp_footer', 'easy_timer_cookies_js'); }


add_filter('get_the_excerpt', 'do_shortcode');
add_filter('get_the_title', 'do_shortcode');
add_filter('single_post_title', 'do_shortcode');
add_filter('the_excerpt', 'do_shortcode');
add_filter('the_excerpt_rss', 'do_shortcode');
add_filter('the_title', 'do_shortcode');
add_filter('the_title_attribute', 'do_shortcode');
add_filter('the_title_rss', 'do_shortcode');
add_filter('widget_text', 'do_shortcode');