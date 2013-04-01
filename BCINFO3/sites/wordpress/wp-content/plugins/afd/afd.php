<?php
/* Plugin Name: AFD */

add_filter('the_content', 'afd');
function afd($content) {return "(in order to read this post, you must register and provide us with a shrubbery)";}

?>
