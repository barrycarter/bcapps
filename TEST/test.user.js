// the real version of this file is named test.user.js and it does at least
// load into GM even if it doesn't work

// generic test greasemonkey script

sel = document.evaluate('//select',
 document, null, XPathResult.ORDERED_NODE_SNAPSHOT_TYPE, null);
sel = sel.snapshotItem(0);

GM_log(sel);

sel.onchange = function(){alert("foo");}


