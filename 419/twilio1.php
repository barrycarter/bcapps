<?php

  // if you call a number that goes to this script, it calls another
  // number and records the whole process

  // NOTE: PHP is probably not necessary, but its a nice place to put
  // comments without screwing up XML, may come in useful later, and
  // means I can use a non-XML extension

  // initial test: tellme (1-800-555-TELL) + time temp

  // I can get twilio numbers easily, first test is to +1 940-468-3927

  // verified scammers and the recordings that verify them:

  // 12147029034 (verified by code words + gmail)

  // 17042492811 james newell (not yet verified)
  // 15856266050 doris brock (not yet verified)

  // Verification procedure:
  //
  // find email with phone number
  // tell sender i am sending code words by phone
  // reset number below to scammer phone number
  // mirror file to live site
  // determine code words (randomly)
  // http://1f59d65c666c69bf8bc52bf5e4c82e27.scowl.db.94y.info may help
  // note down code words for number to see if i get them back
  // prep mac speech code to read form letter
  // call with code words [repeat twice if possible]

header("Content-type: application/xml"); 
echo '<?xml version="1.0" encoding="UTF-8"?>';

?>

<Response>
<Dial record="true">
<Number>+18326868867</Number>
</Dial>
</Response>
