<title><?php echo "$action $type $tabname"?></title>
<center><h1><?php echo "$action $type $tabname"?></h1></center>

<?php

$db = "/home/barrycarter/BCINFO/sites/DB/dfoods.db";

print "HELLO";
debug(sqlite3_command("SELECT COUNT(*) FROM $tabname", $db));
print "GOODBYE";

$count=mysqlval("select count(*) from $tabname");

$res=mysqlhashlist("show columns from $tabname");

?>

There are <?php echo $count ?> records in this table.

<?php
switch ($action) {
 case "quickview": include("quickview.php3"); break;
 case "view": include("viewform.php3"); break;
 case "add": include("addform.php3"); break;
 default: sorry("Action $action not understood");
 }
?>
