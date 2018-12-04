var num = 123;

num.toString().split("").reduce(function(a,b){return parseInt(a)+parseInt(b)});

console.log("this is JS");

function compress(num) 
 {return (num==0?0:(num%10)+compress(Math.floor(num/10)));}

console.log(compress(7474721));

num = 7474721;

// var sum = 0; do {sum += num%10; num-=num%10; num/=10} while (num > 0);

var sum = 0; do {sum += num%10; num=(num-num%10)/10} while (num > 0);

console.log(sum)

