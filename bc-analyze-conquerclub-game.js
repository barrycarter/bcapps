// ==UserScript==
// @name bc-analyze-conquerclub-game.users.js
// @namespace http://conquerclub.barrycarter.info/
// @description Sends an in-progress conquerclub game to server for analysis
// @include *conquerclub*
// ==/UserScript==

// TODO: calling this on every page automatically is excessive; create
// form and allow users to choose when to send

// below stolen from http://rumkin.com/tools/compression/base64.php

var keyStr = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";                                                                             

function encode64(input) { 
  var output = new String(); 
  var chr1, chr2, chr3; 
  var enc1, enc2, enc3, enc4; 
  var i = 0; 

  while (i < input.length) { 
    chr1 = input.charCodeAt(i++); 
    chr2 = input.charCodeAt(i++); 
    chr3 = input.charCodeAt(i++); 

    enc1 = chr1 >> 2; 
    enc2 = ((chr1 & 3) << 4) | (chr2 >> 4); 
    enc3 = ((chr2 & 15) << 2) | (chr3 >> 6); 
    enc4 = chr3 & 63; 

    if (isNaN(chr2)) { 
      enc3 = enc4 = 64; 
    } else if (isNaN(chr3)) { 
      enc4 = 64; 
    }

    output += (keyStr.charAt(enc1) + keyStr.charAt(enc2) + keyStr.charAt(enc3) + keyStr.charAt(enc4)); 
  }

  return output.toString(); 
}

postdata = "json="+document.evaluate('//div[@id="armies"]',document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null).snapshotItem(0).nextSibling.nextSibling.textContent;

post64 = encode64(postdata);

// form w one hidden field for analyze
document.body.innerHTML += ('<form method="POST" action="http://ns1.conquerclub.barrycarter.info/bc-analyze-conquerclub-game.php">');
document.body.innerHTML += '<input type="hidden" name="postdata" value="'+post64+'">';
document.body.innerHTML += '<input type="submit" name="SUBMIT" value="ANALYZE">';
document.body.innerHTML += '</form>';

// send to Perl script that actually does the analysis
GM_xmlhttpRequest({method: "POST", 
url:"http://ns1.conquerclub.barrycarter.info/bc-analyze-conquerclub-game.php",
headers: {'Content-type': 'application/x-www-form-urlencoded'},
data: postdata});

