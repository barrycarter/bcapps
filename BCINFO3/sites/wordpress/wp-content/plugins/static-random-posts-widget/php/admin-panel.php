<?php 
/* Admin Panel Code - Created on April 19, 2008 by Ronald Huereca 
Last modified on October 24, 2009
*/
if (empty($this->adminOptionsName)) { die(''); }

$options = $this->adminOptions; //global settings

//Check to see if a user can access the panel
if (!current_user_can('manage_options') )
	die("nope");

//Update settings
if (isset($_POST['update'])) { 
	check_admin_referer('static-random-posts_admin-options');
	$error = false;
	$updated = false;
	//Validate the time entered
	if (isset($_POST['time'])) {
		$timeErrorMessage = '';
		$timeClass = 'error';
		if (!preg_match('/^\d+$/i', $_POST['time'])) {
			$timeErrorMessage = __("Time must be a numerical value",$this->localizationName);
			$error = true;
		}	elseif($_POST['time'] < 1) {
			$timeErrorMessage = __("Time must be greater than one minute.",$this->localizationName);
			$error = true;
		} else {
			$options['minutes'] = $_POST['time'];
			$updated = true;
		}
		if (!empty($timeErrorMessage)) {
			?>
			<div class="<?php echo $timeClass;?>"><p><strong><?php _e($timeErrorMessage, $this->localizationName);?></p></strong></div>
			<?php
		}
	}
	//categories (add a "-" sign for exclusion)
	for ($i=0; $i<sizeof($_POST['categories']); $i++) {
    $_POST['categories'][$i] = "-" . $_POST['categories'][$i];
	}
	$options['categories'] = $_POST['categories'];

	$updated = true;
	if ($updated && !$error) {
		$this->adminOptions = $options;
		$this->save_admin_options();
		?>
		<div class="updated"><p><strong><?php _e('Settings successfully updated.', $this->localizationName) ?></strong></p></div>
		<?php
	}
}
?>

<div class="wrap">
	 <h2>Static Random Posts Options</h2>
  <form method="post" action="<?php echo $_SERVER["REQUEST_URI"]; ?>">
		<?php wp_nonce_field('static-random-posts_admin-options') ?>
   
    
<table class="form-table">
  <tbody>
    <tr valign="top">
      <th scope="row"><?php _e('Set refresh time (minutes):', $this->localizationName) ?></th>
      <td><input type="text" name="time" value="<?php echo esc_attr($options['minutes']); ?>" id="comment_time"/><p><?php _e('Your random posts will be refreshed every', $this->localizationName); echo " " . $options['minutes'] . " ";_e('minutes.', $this->localizationName);?></p></td>
    </tr>
    <tr valign="top">
        <th scope="row"><?php _e('Exclude Categories:', $this->localizationName) ?></th>
      <td>
        <?php
        $args = array(
			'type'                     => 'post',
			'child_of'                 => 0,
			'orderby'                  => 'name',
			'order'                    => 'ASC',
			'hide_empty'               => false,
			'include_last_update_time' => false,
			'hierarchical'             => 1);
		$categories = get_categories( $args ); 
		foreach ($categories as $cat) {
			$checked = '';
			if (is_array($options['categories'])) {
				if (in_array("-" . $cat->term_id, $options['categories'], false)) {
					$checked = "checked='checked'";
				}
			}
			echo "<input type='checkbox' id='$cat->term_id' value='$cat->term_id' name='categories[]' $checked /> ";
			echo "<label for='$cat->term_id'>$cat->name</label><br />";
		}
		?>
      </td>
    </tr>
 </tbody>
</table>
    <div class="submit">
      <input type="submit" name="update" value="<?php esc_attr_e('Update Settings', $this->localizationName) ?>" />
    </div>
  </form>
</div>