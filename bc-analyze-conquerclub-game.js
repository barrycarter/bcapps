// ==UserScript==
// @name bc-analyze-conquerclub-game.users.js
// @namespace http://conquerclub.barrycarter.info/
// @description Sends an in-progress conquerclub game to server for analysis
// @include *conquerclub*
// ==/UserScript==

// TODO: calling this on every page automatically is excessive; create
// form and allow users to choose when to send

postdata = "json="+document.evaluate('//div[@id="armies"]',document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null).snapshotItem(0).nextSibling.nextSibling.textContent

// send to Perl script that actually does the analysis
GM_xmlhttpRequest({method: "POST", 
url:"http://ns1.conquerclub.barrycarter.info/bc-analyze-conquerclub-game.php",
headers: {'Content-type': 'application/x-www-form-urlencoded'},
data: postdata});

