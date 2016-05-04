var personnr = require('./bc-norwegia');

d = new Date("11112016");

d = new Date("2016-06-31");
console.log(d.toString());

exit(0);

var results = personnr('16111992').make();
console.log(results);

results = personnr('16112015').make();
console.log(results);

