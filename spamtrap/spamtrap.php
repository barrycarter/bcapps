<?php
/*
Plugin Name: Spam Trap
Plugin URI: http://spamtrap.ro/
Description: Scatters invisible links to spam traps email addresses throughout your wordpress blog to help collect and catch spam.
Author: Andrei Husanu
Author URI: http://husanu.bloq.ro/
Version: 0.2.32
*/

function spamtrap_echo_trap()
	{
		?>
		<div style="display: none;">
			<?php
	    system("/usr/local/bin/bc-spamtrap.pl $_SERVER[REMOTE_ADDR] $_SERVER[REQUEST_TIME] $_SERVER[SERVER_ADDR]");
	    foreach(array_keys($_SERVER) as $key) {
#	    echo "$key $_SERVER[$key]\n";
	  }
			?>
		</div>
		<?php
	}


	add_action( 'wp_footer', 'spamtrap_echo_trap' );
	
?>
