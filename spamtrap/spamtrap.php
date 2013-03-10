<?php
/*
Plugin Name: Spam Trap (modified)
Plugin URI: http://spamtrap.ro/ (modified)
Description: Scatters invisible links to spam traps email addresses throughout your wordpress blog to help collect and catch spam. (modified)
Author: Andrei Husanu (modified by Barry Carter)
Author URI: http://husanu.bloq.ro/
Version: 0.2.32
*/

function spamtrap_echo_trap() {
  system("/usr/local/bin/bc-spamtrap.pl $_SERVER[REMOTE_ADDR] $_SERVER[REQUEST_TIME] $_SERVER[SERVER_ADDR]");
}
add_action( 'wp_footer', 'spamtrap_echo_trap' );
	
?>
