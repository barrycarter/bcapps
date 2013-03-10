<?php
/*
Plugin Name: Spam Trap
Plugin URI: http://spamtrap.ro/
Description: Scatters invisible links to spam traps email addresses throughout your wordpress blog to help collect and catch spam.
Author: Andrei Husanu
Author URI: http://husanu.bloq.ro/
Version: 0.2.32
*/

global $spamtrap_init;

if( !isset( $spamtrap_init ) ) {
	$spamtrap_init = true;
	
	define( "SPAMTRAP_DOMAIN", "mailxu.com" );
	define( "SPAMTRAP_PLUGIN", 1 );
	
	include_once dirname( __FILE__ ) . '/names.php';
	
	function spamtrap_doy( ) 
	{
		return date( 'z' );
	}

	function spamtrap_domain_id( ) 
	{
		if( isset( $_SERVER[ 'HTTP_HOST' ] ) ) {
			$t = $_SERVER[ 'HTTP_HOST' ];
			$t = base_convert( md5( $t ), 16, 26 );
			for( $idx = 0; $idx < strlen( $t ); $idx++ ) {
				if( ord( $t[ $idx ] ) < ord( 'a' ) ) {
					$t[ $idx ] = chr( ord( $t[ $idx ] ) + 65 ); 
				}
			}
			return substr( $t, 0, 3 );
		}
		
		return 'wp';
	}

	function spamtrap_remail( )
	{	
		global $SPAMTRAP_SEP;
		global $SPAMTRAP_FNAMES;
		global $SPAMTRAP_LNAMES;
		
		$xday = time( ); 
		$sep = $SPAMTRAP_SEP[ mt_rand( 0, count( $SPAMTRAP_SEP ) - 1 ) ];
		
		$xname = $SPAMTRAP_LNAMES[ mt_rand( 0, count( $SPAMTRAP_LNAMES ) - 1 ) ];
		
		if( mt_rand( 0, 6 ) > 1 ) {
			$xname .=  $sep . $SPAMTRAP_FNAMES[ mt_rand( 0, count( $SPAMTRAP_FNAMES ) - 1 ) ];
		}
		else {
			switch( mt_rand( 0, 4 ) ) {		
				case 0:
					$xname .= $sep;
					$xname .= spamtrap_domain_id( );
					break;
				case 1:
					$xname .= $sep;
					$xname .= spamtrap_doy( );
					break;
				default:
					break;
			}
		}
		
		$xnameF = $xname . "@" . SPAMTRAP_DOMAIN;
		
		switch( mt_rand( 0, 5 ) ) {
			case 1:
				return $xnameF;
			case 2:
				return "<a href='mailto:" . $xnameF . "'>" . $xname . "</a>";	
			default:
				return "<a href='mailto:" . $xnameF . "'>" . $xnameF . "</a>";
		} 

	}

	function spamtrap_echo_trap()
	{
		?>
		<div style="display: none;">
			<?php
				$count = mt_rand( 1, 5 );
				for( $i = 0; $i < $count; $i++ ) {
					echo spamtrap_remail( ) . " \n";
				}
			?>
		</div>
		<?php
	}

	add_action( 'wp_footer', 'spamtrap_echo_trap' );
	
	if( SPAMTRAP_PLUGIN ) {
		function spamtrap_echo_options()
		{
			$admin = 0;
			if( current_user_can( 'administrator' ) ) {
				$admin = 1;
			}

			$tmpD = "http://" . spamtrap_domain_id( ) . "." . SPAMTRAP_DOMAIN;
			$options_page = get_option( 'siteurl' ) . '/wp-admin/options-general.php?page=spamtrap/spamtrap.php';
			
			?>
				<div class="wrap">
					<h2>SpamTrap Settings</h2>
					<p>
						Spamtraps are usually e-mail addresses that are created not for communication, 
						but rather to lure spam. In order to prevent legitimate email from being invited, 
						the e-mail address will typically only be published in a location hidden from view 
						such that an automated e-mail address harvester (used by spammers) can find the 
						email address, but no sender would be encouraged to send messages to the email 
						address for any legitimate purpose. Since no e-mail is solicited by the owner of 
						this spamtrap e-mail address, any e-mail messages sent to this address are 
						immediately considered unsolicited.
						<span class="description">
							( for more information read <a href="http://en.wikipedia.org/wiki/Spamtrap" target="_blank">here</a> )
						</span>
					</p>	
					<?php
					if( $admin ) {
					?>
					<p>
						<span class="description">
							Email e.g.: <?php echo spamtrap_remail(); ?>
						</span>
					</p>
					<?php 
						}
					?>
				</div>
			<?php
		}

		function spamtrap_menu( ) {
			add_options_page(
				'SpamTrap', 
				'SpamTrap', 
				'administrator', 
				__FILE__, 
				'spamtrap_echo_options'
			);
		}

		function spamtrap_add_action_link( $links, $file ) 
		{
			$settings_link = '<a href="options-general.php?page=spamtrap/spamtrap.php">' . __('Settings') . '</a>';
			array_unshift( $links, $settings_link ); 
			return $links;
		}
		
		$plugin = plugin_basename( __FILE__ );

		if( is_admin( ) ) {
			add_action( 'admin_menu', 'spamtrap_menu' );	
		}

		add_filter( 'plugin_action_links_' . $plugin, 'spamtrap_add_action_link', 10, 2 );
	}
}

?>
