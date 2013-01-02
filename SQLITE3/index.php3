<?

// I feel really bad doing this in PHP, but it's way easier to convert
// my old PHP code to new PHP code vs porting from PHP to Perl.

// <h>I consider this my first failure for 2013</h>

require "bclib.php";

// TODO: dont hardcode these
$tables = array("foods");
$db = "/home/barrycarter/BCINFO/sites/DB/dfoods.db";

while (list($k,$v)=each($tables)) {$table[$v]=$v;}

?>

<table border>
<tr><th>Table<th colspan=3>Action
<form action="table.php3" method="GET">
<input type="hidden" name="type" value="table">
  <tr><td><?php print selectmarkedhash("tabname",$table,"\n"); ?>
<td><input type="submit" name="action" value="quickview">
<td><input type="submit" name="action" value="view">
<td><input type="submit" name="action" value="add">
</form></table>


