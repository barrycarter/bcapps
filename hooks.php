<?php

# this file is included into mediawiki's LocalSettings.php for meta wiki purposes

require '/sites/LIB/bclib.php';

# just test hooks for now
$wgHooks['ArticleDeleteComplete'][] = array('perlnotify', 'delete');
$wgHooks['ArticleSaveComplete'][] = array('perlnotify', 'save');
$wgHooks['ArticleInsertComplete'][] = array('perlnotify', 'delete');

# just a test function for now
function perlnotify($type) {
  # only care about changes in the metatestone (wikiname) space
  # TODO: generalize this
  # TODO: re-add this line when ready
  # if (!(preg_match("/^MetaTestOne:/", $_REQUEST[title]))) {return true;}

  # using env variable to reduce code injection
  putenv("PHP_TITLE", $title);
  system("/usr/local/bin/meta-mediawiki.pl");
  return true;
}

?>
