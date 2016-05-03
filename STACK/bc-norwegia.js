module.exports = init;


/**
* Personnr Constructor
* 
* @constructor
* @param {String} birthday
*/


function Personnr(birthday) {
    var bd = makeBirthdayObject(birthday);

    this.birthday   = bd.format
    this.dd         = bd.dd;
    this.mm         = bd.mm;
    this.yy         = bd.yy;
    this.yyyy       = bd.yyyy;

    if (typeof birthday !== 'string')
        throw new Error('Argument must be a string');

    if(!isValidBirthday(this.dd, this.mm, this.yyyy) || 
       birthday.length !== 8) {

        throw new Error('Not valid. Make sure it\'s on the correct format: \'ddMMyyyy\'');
    } 

}

/**
* This actually makes the person-numbers based on the functions below. 
*
* @method make
* @return {Array} Returns an array with all the numbers. 
*/

Personnr.prototype.make = function() {
    var [min, max]  = getRange(this.yyyy),
        individ     = { i1: 0, i2: 0, i3: 0},
        result      = [];

    for(var i = min; i <= max; i++) {
        var {i1, i2, i3}    = generateIndividSiffer(i, individ);
        var [k1, k2]        = generateKontrollSiffer(this.dd, this.mm, this.yy,  {i1, i2, i3});

        var personnr        = [this.birthday, i1, i2, i3, k1, k2].join('');

        if (k1 !== null || k2 !== null) {
            result.push(personnr);   
        }
    }

    return result;
}


function init(birthday) {
    return new Personnr(birthday);
}





/**
* Makes a helper-object from the passed-in birthday
*
* @private
* @method makeBirthdayObject
* @param {Object} bd. This is the birthday that is passed to the constructor
* @return {Object} Returns an object containing different parts of the birthday
*/

function makeBirthdayObject(bd) {
    var birthday = {
        dd      : parseInt(bd.slice(0, 2)),
        mm      : parseInt(bd.slice(2, 4)),
        yy      : parseInt(bd.slice(6, 8)),
        yyyy    : parseInt(bd.slice(4, 8)),
        format  : [bd.slice(0, 2), bd.slice(2, 4), bd.slice(6, 8)].join('')
    };

    return birthday;
}


/**
* Determines of the birthday is valid.
*
* @private
* @method isValidBirthday
* @param {Number} day
* @param {Number} month
* @param {Number} year
* @return {Boolean} Returns true if the birthday is valid
*/

function isValidBirthday(day, month, year) {

    var leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);

    var days = {
        1: 31, 2: leapYear ? 29 : 28, 3: 31, 4: 30, 
        5: 31, 6: 30, 7: 31, 8: 31, 
        9: 30, 10: 31, 11: 30, 12: 31
    };

    if (year < 1900 || year > 2039)     return false;
    if (month < 1 || month > 12)        return false;

    if (day < 1 || day > days[month])   return false;

    return true;

}



/**
* Generates the range used in the main loop
*
* @private
* @method getRange
* @param {Number} year
* @return {Array} Return a min and max range as an Array
*/

function getRange(year) {

    return isBetween(1900, 1999, year) ? [0, 499]   :
           isBetween(2000, 2039, year) ? [500, 999] : [null, null];

    return [min, max];

    function isBetween(min, max, x) { 
        return x >= min && x < max 
    }
}


/**
* Generates the 'Individ'-numbers (i1, i2, i3). The range depends on the year.
* 000-499 for people born some time in 1900-1999.
* 500-999 for people born some time in 2000-2039.
*
* @private
* @method generateIndividSiffer
* @param {Number} increment
* @param {Object} individ
* @return {Object} Returns i1, i2, i3 as an Object
*/

function generateIndividSiffer(increment, individ) {
    function divmod(n, d) {
        return parseInt(increment / n) % d;
    }

    var {i1, i2, i3} = individ;

    if (increment < 100)  
        ({i1, i2} = {i1: 0, i2: divmod(10, 10)});
    else if (increment < 10) 
        ({i1, i2} = {i1: 0, i2: 0});
    else 
        ({i1, i2} = {i1: divmod(100, 10), i2: divmod(10, 10)});

    i3 = increment % 10

    return {i1, i2, i3};
}

/**
* Generate the last part of the social security-number (k1, k2)
*
* @private
* @method generateKontrollSiffer
* @param {Number} day
* @param {Number} month
* @param {Number} year
* @param {Object} individ
* @return {Array} Return k1 and k2 as an Array
*/

function generateKontrollSiffer(day, month, year, individ) {   

    function divmod(n, d) { 
        return [parseInt(n/d), n % d];
    }

    var [d1, d2]  = divmod(day, 10),
        [m1, m2]  = divmod(month, 10),
        [y1, y2]  = divmod(year, 10),

        {i1, i2, i3} = individ;


    var k1 = 11 - ((3*d1 + 7*d2 + 6*m1 + 1*m2 + 8*y1 + 9*y2 + 4*i1 + 5*i2 + 2*i3) % 11); 
    var k2 = 11 - ((5*d1 + 4*d2 + 3*m1 + 2*m2 + 7*y1 + 6*y2 + 5*i1 + 4*i2 + 3*i3 + 2*k1) % 11);

    return (k1 < 10 && k2 < 10) ? [k1, k2] : [null, null];


}
