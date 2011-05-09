<?php $easy_timer_default_options = array(
'cookies_lifetime' => 15,
'default_timer_prefix' => 'dhms',
'javascript_enabled' => 'yes');

$easy_timer_options = get_option('easy_timer');
foreach ($easy_timer_default_options as $key => $value) {
if ($easy_timer_options[$key] == '') { $easy_timer_options[$key] = $easy_timer_default_options[$key]; } }
update_option('easy_timer', $easy_timer_options);