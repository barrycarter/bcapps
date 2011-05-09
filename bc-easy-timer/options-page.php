<?php if (!current_user_can('manage_options')) { wp_die(__('You do not have sufficient permissions to access this page.')); }

if ((isset($_POST['submit'])) && (check_admin_referer($_GET['page']))) {
$_POST = array_map('html_entity_decode', $_POST);
$_POST = array_map('stripslashes', $_POST);
$cookies_lifetime = (int) $_POST['cookies_lifetime']; if (empty($cookies_lifetime)) { $cookies_lifetime = 15; }
$default_timer_prefix = $_POST['default_timer_prefix'];
if ($_POST['javascript_enabled'] == 'yes') { $javascript_enabled = 'yes'; } else { $javascript_enabled = 'no'; }

$easy_timer_options = array(
'cookies_lifetime' => $cookies_lifetime,
'default_timer_prefix' => $default_timer_prefix,
'javascript_enabled' => $javascript_enabled);
update_option('easy_timer', $easy_timer_options); }

if (!isset($easy_timer_options)) { $easy_timer_options = get_option('easy_timer'); }
$easy_timer_options = array_map('htmlspecialchars', $easy_timer_options); ?>

<div class="wrap">
<h2>Easy Timer</h2>
<?php if (isset($_POST['submit'])) { echo '<div class="updated"><p><strong>'.__('Settings saved.').'</strong></p></div>'; } ?>
<p style="margin: 1.5em"><a href="http://www.kleor-editions.com/easy-timer"><?php _e('Documentation', 'easy-timer'); ?></a></p>
<h3><?php _e('Options', 'easy-timer'); ?></h3>
<form method="post" action="<?php echo htmlspecialchars($_SERVER['REQUEST_URI']); ?>">
<?php wp_nonce_field($_GET['page']); ?>
<p><label for="default_timer_prefix"><?php _e('The <code>[timer]</code> shortcode is equivalent to', 'easy-timer'); ?>:</label> 
<select name="default_timer_prefix" id="default_timer_prefix">
<option value="dhms"<?php if ($easy_timer_options['default_timer_prefix'] == 'dhms') { echo ' selected="selected"'; } ?>>[dhmstimer]</option>
<option value="dhm"<?php if ($easy_timer_options['default_timer_prefix'] == 'dhm') { echo ' selected="selected"'; } ?>>[dhmtimer]</option>
<option value="dh"<?php if ($easy_timer_options['default_timer_prefix'] == 'dh') { echo ' selected="selected"'; } ?>>[dhtimer]</option>
<option value="d"<?php if ($easy_timer_options['default_timer_prefix'] == 'd') { echo ' selected="selected"'; } ?>>[dtimer]</option>
<option value="hms"<?php if ($easy_timer_options['default_timer_prefix'] == 'hms') { echo ' selected="selected"'; } ?>>[hmstimer]</option>
<option value="hm"<?php if ($easy_timer_options['default_timer_prefix'] == 'hm') { echo ' selected="selected"'; } ?>>[hmtimer]</option>
<option value="h"<?php if ($easy_timer_options['default_timer_prefix'] == 'h') { echo ' selected="selected"'; } ?>>[htimer]</option>
<option value="ms"<?php if ($easy_timer_options['default_timer_prefix'] == 'ms') { echo ' selected="selected"'; } ?>>[mstimer]</option>
<option value="m"<?php if ($easy_timer_options['default_timer_prefix'] == 'm') { echo ' selected="selected"'; } ?>>[mtimer]</option>
<option value="s"<?php if ($easy_timer_options['default_timer_prefix'] == 's') { echo ' selected="selected"'; } ?>>[stimer]</option>
</select>. <a href="http://www.kleor-editions.com/easy-timer/#timer-shortcodes"><?php _e('More informations', 'easy-timer'); ?></a><br />
<?php _e('The <code>[total-timer]</code> shortcode is equivalent to', 'easy-timer'); ?> <code>[total-<?php echo $easy_timer_options['default_timer_prefix']; ?>timer]</code>.<br />
<?php _e('The <code>[elapsed-timer]</code> shortcode is equivalent to', 'easy-timer'); ?> <code>[elapsed-<?php echo $easy_timer_options['default_timer_prefix']; ?>timer]</code>.<br />
<?php _e('The <code>[total-elapsed-timer]</code> shortcode is equivalent to', 'easy-timer'); ?> <code>[total-elapsed-<?php echo $easy_timer_options['default_timer_prefix']; ?>timer]</code>.<br />
<?php _e('The <code>[remaining-timer]</code> shortcode is equivalent to', 'easy-timer'); ?> <code>[remaining-<?php echo $easy_timer_options['default_timer_prefix']; ?>timer]</code>.<br />
<?php _e('The <code>[total-remaining-timer]</code> shortcode is equivalent to', 'easy-timer'); ?> <code>[total-remaining-<?php echo $easy_timer_options['default_timer_prefix']; ?>timer]</code>.</p>
<p><label for="cookies_lifetime"><?php _e('Cookies lifetime (used for relative dates)', 'easy-timer'); ?>:</label> <input type="text" name="cookies_lifetime" id="cookies_lifetime" value="<?php echo $easy_timer_options['cookies_lifetime']; ?>" size="4" /> <?php _e('days', 'easy-timer'); ?> <a href="http://www.kleor-editions.com/easy-timer/#relative-dates"><?php _e('More informations', 'easy-timer'); ?></a></p>
<p><input type="checkbox" name="javascript_enabled" id="javascript_enabled" value="yes"<?php if ($easy_timer_options['javascript_enabled'] == 'yes') { echo ' checked="checked"'; } ?> /> <label for="javascript_enabled"><?php _e('Add JavaScript code', 'easy-timer'); ?></label><br />
<span class="description"><?php _e('If you uncheck this box, Easy Timer will never add any JavaScript code to the pages of your website, but your count up/down timers will not refresh.', 'easy-timer'); ?></span></p>
<p class="submit" style="margin: 0 20%;"><input type="submit" class="button-primary" name="submit" id="submit" value="<?php _e('Save Changes'); ?>" /></p>
</form>
</div>