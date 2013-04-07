<?php
/*
Plugin Name: BC Timer
Description: Timer modified from http://www.kleor-editions.com/easy-timer
Version: particleman
Author: Barry Carter
Author URI: http://barrycarter.info
*/

// include the required JS
$url = plugin_dir_url(__FILE__);
// echo "<script type='text/javascript' src='$url/bc-timer.js' />";

// put [bctimer time="time_in_unix_seconds" format="format_in_strftimeish"]
add_shortcode('bctimer', 'bctimer');

// whenever we see this shortcode, just put a span class
function bctimer ($atts) {
  echo "<span class='bctimer' id='$atts[time]' format='$atts[format]'></span>";
}

?>
