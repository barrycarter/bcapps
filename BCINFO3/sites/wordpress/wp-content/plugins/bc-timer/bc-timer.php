<?php
/*
Plugin Name: BC Timer
Description: Timer modified from http://www.kleor-editions.com/easy-timer
Version: particleman
Author: Barry Carter
Author URI: http://barrycarter.info
*/

// TODO: allow fractional time units

// the JS I need
wp_enqueue_script('bctimer', '/wp-content/plugins/bc-timer/bc-timer.js');

// put [bctimer time="time_in_unix_seconds" format="format_in_strftimeish"]
add_shortcode('bctimer', 'bctimer');

// and work in widgets too
add_filter('widget_text', 'do_shortcode');

// whenever we see this shortcode, just put a span class
function bctimer ($atts) {
  return "<span class='bctimer' time='$atts[time]' format='$atts[format]'></span>";
}

?>
