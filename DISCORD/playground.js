var proc = require('child_process');

var out = proc.execFileSync('/bin/date', {encoding: 'buffer', maxBuffer: 100});

console.log(out);

// exit();

// var date = await exec('/bin/date');

// console.log(date.output);

// function pdate(res, out, err) {console.log(out);}
