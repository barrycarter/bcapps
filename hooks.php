<?php

# this file is included into mediawiki's LocalSettings.php for meta wiki purposes

require '/sites/LIB/bclib.php';

# just test hooks for now
$wgHooks['ArticleDeleteComplete'][] = array('perlnotify', 'delete');
$wgHooks['ArticleSaveComplete'][] = array('perlnotify', 'save');
# $wgHooks['ArticleInsertComplete'][] = ('perlnotify', 'delete');

# just a test function for now
function perlnotify($type) {
  filedebug(var_dump_ret($_REQUEST));
  return true;
}

?>
