<?php

/*

Plugin Name: Wondertwin Powers
Description: Combines some plugins I use (wp-click-tracker, auto-hyperlink-urls, spamtrap, maybe others)
Version: Gleek
Author: Barry Carter <carter.barry@gmail.com>
License: GPL

*/

add_filter('the_content', 'wt_filter');

// filter URLs and stuff
function wt_filter($content) {
  // convert things like plivo.com to proper urls
  $content=preg_replace("/([a-z0-9]+\.[a-z]{2,})([^a-z]|$)/i", "http://$1$2", $content);
  // Now handle all fully qualified URLs
  $content=preg_replace_callback("%(https?://\S+?)(\s|<|>|$)%", "url_filter", $content);
  
  return $content;
}

function url_filter($regex) {
  return base64_encode($regex[1]).$regex[2];
}

?>
