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
attack = document.evaluate('//ul', document, null, XPathResult.UNORDERED_NODE_SNAPSHOT_TYPE, null);
GM_log("ALPHA");
GM_log(attack.snapshotItem(1));
GM_log("BETA");

