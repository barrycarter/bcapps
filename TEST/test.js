// the real version of this file is named test.user.js and it does at least
// load into GM even if it doesn't work

// When I run this script on the page below
// @include http://test.barrycarter.info/select1.html
// I want it to alert "foo" everytime I change selections.
// Instead, I get "Error: Component is not available"

// NOTE: works fine in firebug

// generic test greasemonkey script

sel = document.evaluate('//select',
 document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
sel = sel.snapshotItem(0);

GM_log(sel);

/// sel.onchange = function(){alert("foo");}

sel.addEventListener("change", function(){alert("foo");}, false);



