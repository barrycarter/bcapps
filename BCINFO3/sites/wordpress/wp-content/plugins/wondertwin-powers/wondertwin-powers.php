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
  // handle fully qualified URLs (need > for end of HTML tag)
  $content=preg_replace_callback("%(\s|^|>)(https?://[^\s<>]+)%", "url_filter", $content);
  // and the rest... <h>(here on Gilligan's Isle!)</h>
  $content=preg_replace_callback("/(\s|^|>)([a-z0-9\.]+\.[a-z]{2,})([^a-z0-9])/i", "url_filter", $content);
  
  return $content;
}

function url_filter($regex) {
  // just for testing
  if (!preg_match("%http://%i", $regex[2])) {
    return "$regex[1]<a href='http://$regex[2]'>$regex[2]</a>$regex[3]";
  }

  return "$regex[1]<a href='$regex[2]'>$regex[2]</a>";

  return "GOT($regex[1], $regex[2])";

  // TODO: don't redirect my own URLs, semi-pointless


  return '<a href="http://u.94y.info/'.base64_encode($regex[1]).'">'.$regex[1].'</a>'.$regex[2];
}

?>
