<?php function easy_timer_options_page() { include 'options-page.php'; }

function easy_timer_admin_menu() {
add_options_page('Easy Timer', 'Easy Timer', 'manage_options', 'easy-timer', 'easy_timer_options_page'); }

add_action('admin_menu', 'easy_timer_admin_menu');


function easy_timer_row_meta($links, $file) {
if ($file == 'easy-timer/easy-timer.php') {
return array_merge($links, array(
'<a href="options-general.php?page=easy-timer">'.__('Options', 'easy-timer').'</a>',
'<a href="http://www.kleor-editions.com/easy-timer">'.__('Documentation', 'easy-timer').'</a>')); }
return $links; }

add_filter('plugin_row_meta', 'easy_timer_row_meta', 10, 2);