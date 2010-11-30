<?php

# write debugging info to file (why? because redirects/etc means end
# user cant always see debug info)

function filedebug ($str) {
  // TODO: make this MUCH fancier incl timestamps + identify caller
  $fh = fopen("/tmp/debug.txt","a");
  fwrite($fh,microtime()." $str\n");
  fclose($fh);
}

# parse_args(aa): more flexible argument passing. Instead of passing
# arguments by position, parse_args allows setting variables in the
# target function. A single argument "x=1&y=2&z=3..." sets x=1, y=2,
# z=3, while two adjacent arguments
# ("u",array('a'=>'apple','b'=>'boat')) can be used to set more
# complicated values (in this case setting u to an associative array)

function parse_args ($aa) {
  # if $aa isn't an array, make it one
  if (!is_array($aa)) {$aa = array($aa);}

  $ag=sizeof($aa);
  for ($j=0; $j<$ag; $j++) {
    $val=$aa[$j];

    if (strstr($val,"=")) {
      # single arg setting multiple values (like x=1&y=2&z=3)
      $ab=preg_split("/[=&]/",$val);
      $ae=sizeof($ab); # compute only once for efficiency
      for ($i=0; $i<$ae; $i+=2) {
	$ad[$ab[$i]]=$ab[$i+1];
      }
    } else {
      # two adjacent args setting a single value (like "x",7)
      $ad[$val]=current($aa);
      next($aa);
    }
  }
  return($ad);
}

function textarea($name,$value="",$options="") {
  # defaults overriden by options
  $hash = array_merge(parse_args("cols=70&rows=10"),parse_args($options));
  return "<textarea name='$name' cols=$hash[cols] rows=$hash[rows]>$value</textarea>";
}

function textentry($name,$value="",$options="") {
  # defaults overriden by options
  $hash = array_merge(parse_args("size=10"),parse_args($options));
  return "<input type='text' name='$name' value='$value' size='$hash[size]'>";
}

# selectmarkedhash(name,hash,marked,extra): create a HTML form select
# field named "name", based on "hash", selecting "marked", extra HTML
# passed in "extra"; sets secure hash (based on $salt) to prevent
# choose-your-own-value hack

function selectmarkedhash($name,$hash,$options="") {
  $opts = array_merge(parse_args("salt=NaCl"),parse_args($options));

  $result="<select name=\"$name\" $hash[extra]>\n";
  while(list($key,$val)=each($hash)) {
    $selected=(($key==$opts[marked])?"selected":"");
    $result=$result."<option value=\"$key\" $selected>$val\n";
  }
  $result=$result."</select>\n";

  # the array keys as a CSV
  $keys = implode(",", array_keys($hash));

  # determine salted encrypt hash + BASE64 encode it
  # @ suppresses the "empty IV" error
  $encrypt = @mcrypt_ecb(MCRYPT_RIJNDAEL_256,$opts[salt],$keys,MCRYPT_ENCRYPT);
  $encrypt = base64_encode($encrypt);

  # and return a hidden field for it
  $result=$result."<input type='hidden' name='salt[$name]' value='$encrypt'>";

  return($result);
}

# convert list to hash

function list2hash($arr) {
  $retval = array();
  foreach ($arr as $i) {$retval[$i]=$i;}
  return $retval;
}

# print string if $DEBUG set
function debug($string) {
  global $DEBUG;
  if ($DEBUG) {print("<b>DEBUG</b>:<pre>$string</pre><br>\n");}
}

# run a command, return out, err, and exit status

function run_command($command,$options="") {
  // where to store results
  $out = tempnam("/tmp","ktj");
  // TODO: could I use $out = system() here?
  system("($command) 1> $out 2> $out.err", $res);
  return array(file_get_contents($out), file_get_contents("$out.err"), $res);
}

function var_dump_ret($mixed = null) { 
  ob_start(); 
  var_dump($mixed); 
  $content = ob_get_contents(); 
  ob_end_clean(); 
  return $content; 
}

?>