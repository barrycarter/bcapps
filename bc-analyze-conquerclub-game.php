<?php

// PHP script to pipe data from bc-analyze-conquerclub-game.user.js to Perl

$fname = "/tmp/phpinfo".time().".html";
ob_start();
phpinfo();
$phpinfo = ob_get_contents();
ob_end_clean();
$fh=fopen($fname,"w");
fwrite($fh,$phpinfo);
fclose($fh);

// using a PHP script solely to call a Perl script is admittedly weird
system("/usr/local/bin/bc-analyze-conquerclub-game.pl $fname");

?>

