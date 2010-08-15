// ==UserScript==
// @name bc-log-die-rolls.users.js
// @namespace http://barrycarter.info/
// @description Logs all conquerclub.com die rolls to central server
// intentionally not putting http below, I want to match files too
// @include *conquerclub*
// ==/UserScript==


// TODO: production include is: http://www.conquerclub.com/game.php?game=*

// currently in testing mode as I learn greasemonkey/JS
// test page:
// http://conquerclub.barrycarter.info/TEST/conquerclub.snapshot.diceroll.html

var attack;
attack = document.evaluate('//ul', document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);

GM_log("ALPHA "+attack.snapshotItem(1));
GM_log(dump(attack.snapshotItem(1).textContent));
GM_log("BETA");

/**
 * Function : dump()
 * Arguments: The data - array,hash(associative array),object
 *    The level - OPTIONAL
 * Returns  : The textual representation of the array.
 * This function was inspired by the print_r function of PHP.
 * This will accept some data as the argument and return a
 * text that will be a more readable version of the
 * array/hash/object that is given.
 * Docs: http://www.openjs.com/scripts/others/dump_function_php_print_r.php
 */
function dump(arr,level) {
  var dumped_text = "";
  if(!level) level = 0;
  
  //The padding given at the beginning of the line.
  var level_padding = "";
  for(var j=0;j<level+1;j++) level_padding += "    ";
  
  if(typeof(arr) == 'object') { //Array/Hashes/Objects 
    for(var item in arr) {
      var value = arr[item];
      
      if(typeof(value) == 'object') { //If it is an array,
	dumped_text += level_padding + "'" + item + "' ...\n";
	dumped_text += dump(value,level+1);
      } else {
	dumped_text += level_padding + "'" + item + "' => \"" + value + "\"\n";
      }
    }
  } else { //Stings/Chars/Numbers etc.
    dumped_text = "===>"+arr+"<===("+typeof(arr)+")";
  }
  return dumped_text;
}
