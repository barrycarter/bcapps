<?php
/*
Plugin Name: BC Timer
Description: Timer modified from http://www.kleor-editions.com/easy-timer
Version: particleman
Author: Barry Carter
Author URI: http://barrycarter.info
*/

// the JS I need
wp_enqueue_script('bctimer', '/wp-content/plugins/bc-timer/bc-timer.js');

// put [bctimer time="time_in_unix_seconds" format="format_in_strftimeish"]
add_shortcode('bctimer', 'bctimer');

// whenever we see this shortcode, just put a span class
function bctimer ($atts) {
  echo "<span class='bctimer' id='$atts[time]' format='$atts[format]'></span>";
}

?>
