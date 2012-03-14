<?php

# this is just for regular semantic stuff
include_once("$IP/extensions/SemanticMediaWiki/SemanticMediaWiki.php"); 
enableSemantics('wiki.barrycarter.info'); 

$smwgShowFactbox = SMW_FACTBOX_NONEMPTY;
$smwgBrowseShowInverse = true;

# this file is included into mediawiki's LocalSettings.php for meta wiki purposes

require '/sites/LIB/bclib.php';

# just test hooks for now
$wgHooks['ArticleDeleteComplete'][] = array('perlnotify', 'delete');
$wgHooks['ArticleSaveComplete'][] = array('perlnotify', 'save');
$wgHooks['ArticleInsertComplete'][] = array('perlnotify', 'delete');

# just a test function for now
function perlnotify($type) {
  # ignore changes except in wiki namespace
  # TODO: generalize this
  if (!(preg_match("/^Sample:/", $_REQUEST[title]))) {return true;}

  # using tmpfile to reduce code injection
  $file = tempnam("/tmp/","metamedia");
  file_put_contents($file, $_REQUEST[title]);
  system("/usr/local/bin/meta-mediawiki.pl --debug $file 1> /tmp/stdout.txt 2> /tmp/stderr.txt");
  return true;
}

?>
