<?php
/*
Plugin Name: Static Random Posts Widget
Plugin URI: http://www.ronalfy.com/2009/10/26/wordpress-static-random-post
Description: This plugin allows the display of random posts, but allows the user to determine how often the random posts are refreshed. 
Author: Ronald Huereca
Version: 1.2
Requires at least: 2.9.2
Author URI: http://www.ronalfy.com/
Some code borrowed from Advanced Random Posts - http://www.yakupgovler.com/?p=416
*/ 

if (!class_exists('static_random_posts')) {
    class static_random_posts	extends WP_Widget {		
			var $localizationName = "staticRandom";
			var $adminOptionsName = "static-random-posts";
			var $plugin_url = '';
			
			/**
			* PHP 4 Compatible Constructor
			*/
			function static_random_posts(){
				$this->adminOptions = $this->get_admin_options();
				$this->plugin_url = rtrim( plugin_dir_url(__FILE__), '/' );
				
				//Initialization stuff
				add_action('init', array(&$this, 'init'));
				
				//Admin options
				add_action('admin_menu', array(&$this,'add_admin_pages'));
				//JavaScript
				add_action('wp_print_scripts', array(&$this,'add_post_scripts'),1000);
				//Ajax
				add_action('wp_ajax_refreshstatic', array(&$this, 'ajax_refresh_static_posts'));
				add_action('wp_ajax_nopriv_refreshstatic', array(&$this, 'ajax_refresh_static_posts'));
				//Widget stuff
				$widget_ops = array('description' => __('Shows Static Random Posts.', 'staticRandom') );
				//Create widget
				$this->WP_Widget('staticrandomposts', __('Static Random Posts', 'staticRandom'), $widget_ops);
			}
			
			//Build new posts and send back via Ajax
			function ajax_refresh_static_posts() {
				check_ajax_referer('refreshstaticposts');
				if ( isset($_POST['number']) ) {
					$number = absint($_POST['number']);
					$action = sanitize_text_field( $_POST['action'] );
					$name = sanitize_text_field( $_POST['name'] );
					
					//Get the SRP widgets
					$settings = get_option($name);
					$widget = $settings[$number];
					
					//Get the new post IDs
					$widget = $this->build_posts(intval($widget['postlimit']),$widget);
					$post_ids = $widget['posts'];
					
					//Save the settings
					$settings[$number] = $widget;
					
					//Only save if user is admin
					if ( is_user_logged_in() && current_user_can( 'administrator' ) ) {
						update_option($name, $settings);
						
						//Let's clean up the cache
						//Update WP Super Cache if available
						if(function_exists("wp_cache_clean_cache")) {
							@wp_cache_clean_cache('wp-cache-');
						}
					}
					//Build and send the response
					die( $this->print_posts( $post_ids, false ) );
				}
				exit;			
			} //end ajax_refresh_static_posts
			
			/* init - Run upon WordPress initialization */
			function init() {
				//* Begin Localization Code */
				$static_random_posts_locale = get_locale();
				$static_random_posts_mofile = WP_PLUGIN_DIR . "/static-random-posts/languages/" . 'staticRandom' . "-". $static_random_posts_locale.".mo";
				load_textdomain('staticRandom', $static_random_posts_mofile);
			//* End Localization Code */
			}//end function init
						
						
			// widget - Displays the widget
			function widget($args, $instance) {
				extract($args, EXTR_SKIP);
				echo $before_widget;
				$title = empty($instance['title']) ? __('Random Posts', 'staticRandom') : apply_filters('widget_title', $instance['title']);
				$allow_refresh = isset( $instance[ 'allow_refresh' ] ) ? $instance[ 'allow_refresh' ] : 'false';
				
				if ( !empty( $title ) ) {
					echo $before_title . $title . $after_title;
				};
				//Get posts
				$post_ids = $this->get_posts($instance);
				if (!empty($post_ids)) {
					echo "<ul class='static-random-posts' id='static-random-posts-{$this->number}'>";
					$this->print_posts($post_ids);
					echo "</ul>";
					if (current_user_can('administrator') || 'true' == $allow_refresh ) {
						$refresh_url = esc_url( wp_nonce_url(admin_url("admin-ajax.php?action=refreshstatic&number=$this->number&name=$this->option_name"), "refreshstaticposts"));
						echo "<br /><a href='$refresh_url' class='static-refresh'>" . __("Refresh...",'staticRandom') . "</a>";
					}
				}
				echo $after_widget;
			}
			
			//Prints or returns the LI structure of the posts
			function print_posts($post_ids,$echo = true) {
				if (empty($post_ids)) { return ''; }
				$posts = get_posts("include=$post_ids");
				$posts_string = '';
				foreach ($posts as $post) {
					$posts_string .= "<li><a href='" . get_permalink($post->ID) . "' title='". esc_attr($post->post_title) ."'>" . esc_html($post->post_title) ."</a></li>\n";
				}
				if ($echo) {
					echo $posts_string;
				} else {
					return $posts_string;
				}
			}
			
			//Returns the post IDs of the posts to retrieve
			function get_posts($instance, $build = false) {
				//Get post limit
				$limit = intval($instance['postlimit']);
				
				$all_instances = $this->get_settings();
				//If no posts, add posts and a time
				if (empty($instance['posts'])) {
					//Build the new posts
					$instance = $this->build_posts($limit,$instance);
					$all_instances[$this->number] = $instance;
					update_option( $this->option_name, $all_instances );
				}  elseif(($instance['time']-time()) <=0) {
					//Check to see if the time has expired
					//Rebuild posts
					$instance = $this->build_posts($limit,$instance);
					$all_instances[$this->number] = $instance;
					update_option( $this->option_name, $all_instances );
				} elseif ($build == true) {
					//Build for the heck of it
					$instance = $this->build_posts($limit,$instance);
					$all_instances[$this->number] = $instance;
					update_option( $this->option_name, $all_instances );
				}
				if (empty($instance['posts'])) {
					$instance['posts'] = '';
				}
				return $instance['posts'];
			}
			
			/**
			* get_plugin_url()
			* 
			* Returns an absolute url to a plugin item
			*
			* @param		string    $path	Relative path to plugin (e.g., /css/image.png)
			* @return		string               An absolute url (e.g., http://www.domain.com/plugin_url/.../css/image.png)
			*/
			function get_plugin_url( $path = '' ) {
				$dir = $this->plugin_url;
				if ( !empty( $path ) && is_string( $path) )
					$dir .= '/' . ltrim( $path, '/' );
				return $dir;	
			} //get_plugin_url
	
			//Builds and saves posts for the widget
			function build_posts($limit, $instance) {
				//Get categories to exclude
				$cats = @implode(',', $this->adminOptions['categories']);
				
				$posts = get_posts("cat=$cats&showposts=$limit&orderby=rand"); //get posts by random
				$post_ids = array();
				foreach ($posts as $post) {
					array_push($post_ids, $post->ID);
				}
				$post_ids = implode(',', $post_ids);
				$instance['posts'] = $post_ids;
				$instance['time'] = time()+(60*intval($this->adminOptions['minutes']));
				
				return $instance;
			}
			
			//Updates widget options
			function update($new, $old) {
				$instance = $old;
				$instance['postlimit'] = intval($new['postlimit']);
				$instance['title'] = sanitize_text_field( $new['title'] );
				$instance[ 'allow_refresh' ] = $new[ 'allow_refresh' ] == 'true' ? 'true' : 'false';
				return $instance;
			}
						
			//Widget form
			function form($instance) {
				$instance = wp_parse_args( 
					(array)$instance, 
					array(
						'title'=> __( "Random Posts", 'staticRandom' ),
						'postlimit'=>5,
						'posts'=>'', 
						'time'=>'',
						'allow_refresh' => 'false',
				) );
				$postlimit = intval($instance['postlimit']);
				$posts = $instance['posts'];
				$title = esc_attr($instance['title']);
				$allow_refresh = $instance[ 'allow_refresh' ];
				?>
			<p>
				<label for="<?php echo esc_attr($this->get_field_id('title')); ?>"><?php _e("Title", 'staticRandom'); ?><input class="widefat" id="<?php echo esc_attr($this->get_field_id('title')); ?>" name="<?php echo esc_attr($this->get_field_name('title')); ?>" type="text" value="<?php echo esc_attr($title); ?>" />
				</label>
			</p>
			<p>
				<label for="<?php echo esc_attr($this->get_field_id('postlimit')); ?>"><?php _e("Number of Posts to Show", 'staticRandom'); ?><input class="widefat" id="<?php echo esc_attr($this->get_field_id('postlimit')); ?>" name="<?php echo esc_attr($this->get_field_name('postlimit')); ?>" type="text" value="<?php echo esc_attr($postlimit); ?>" />
				</label>
			</p>
			<p>
				<?php esc_html_e( 'Allow users to refresh the random posts?', 'staticRandom' ); ?>
				<input type="radio" name="<?php echo esc_attr( $this->get_field_name( 'allow_refresh' ) ); ?>" id="<?php echo esc_attr( $this->get_field_id( 'allow_refresh_yes' ) ); ?>" value="true" <?php checked( 'true', $allow_refresh ); ?>/>
				<label for="<?php echo esc_attr( $this->get_field_id( 'allow_refresh_yes' ) ); ?>"><?php esc_html_e( 'Yes', 'staticRandom' ); ?></label><br />
				<input type="radio" name="<?php echo esc_attr( $this->get_field_name( 'allow_refresh' ) ); ?>" id="<?php echo esc_attr( $this->get_field_id( 'allow_refresh_no' ) ); ?>" value="false" <?php checked( 'false', $allow_refresh ); ?> />
				<label for="<?php echo esc_attr( $this->get_field_id( 'allow_refresh_no' ) ); ?>"><?php esc_html_e( 'No', 'staticRandom' ); ?></label>
			</p>
			<p><?php _e("Please visit",'staticRandom')?> <a href="options-general.php?page=static-random-posts.php"><?php _e("Static Random Posts",'staticRandom')?></a> <?php _e("to adjust the global settings",'staticRandom')?>.</p>
			<?php
			}//End function form
						/*BEGIN UTILITY FUNCTIONS - Grouped by function and not by name */
			function add_admin_pages(){
				add_options_page('Static Random Posts', 'Static Random Posts', 'administrator', basename(__FILE__), array(&$this, 'print_admin_page'));
			}
			//Provides the interface for the admin pages
			function print_admin_page() {
				include dirname(__FILE__) . '/php/admin-panel.php';
			}
			//Returns an array of admin options
			function get_admin_options() {
				if (empty($this->adminOptions)) {
					$adminOptions = array(
						'minutes' => '5',
						'categories' => ''
					);
					$options = get_option($this->adminOptionsName);
					if (!empty($options)) {
						foreach ($options as $key => $option) {
							if (array_key_exists($key, $adminOptions)) {
								$adminOptions[$key] = $option;
							}
						}
					}
					$this->adminOptions = $adminOptions;
					$this->save_admin_options();								
				}
				return $this->adminOptions;
			}
			//Saves for admin 
			function save_admin_options(){
				if (!empty($this->adminOptions)) {
					update_option($this->adminOptionsName, $this->adminOptions);
				}
			}
			//Add scripts to the front-end of the blog
			function add_post_scripts() {
				//Only load the widget if the widget is showing
				if ( !is_active_widget(true, $this->id, $this->id_base) || is_admin() ) { return; }
				
				//queue the scripts
				wp_enqueue_script("wp-ajax-response");
				wp_enqueue_script('static_random_posts_script', $this->get_plugin_url( '/js/static-random-posts.js' ), array( "jquery" ) , 1.0);
				wp_localize_script( 'static_random_posts_script', 'staticrandomposts', $this->get_js_vars());
			}
			//Returns various JavaScript vars needed for the scripts
			function get_js_vars() {
				return array(
					'SRP_Loading' => esc_js(__('Loading...', 'staticRandom')),
					'SRP_Refresh' => esc_js(__('Refresh...', 'staticRandom')),
					'SRP_AjaxUrl' =>  admin_url('admin-ajax.php')
				);
			} //end get_js_vars
			/*END UTILITY FUNCTIONS*/
    }//End class
}
add_action('widgets_init', create_function('', 'return register_widget("static_random_posts");') );
?>