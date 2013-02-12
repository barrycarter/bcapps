<?php

  // if you call a number that goes to this script, it calls another
  // number and records the whole process

  // NOTE: PHP is probably not necessary, but its a nice place to put
  // comments without screwing up XML, may come in useful later, and
  // means I can use a non-XML extension

  // initial test: tellme (1-800-555-TELL)

header("Content-type: application/xml"); 
echo '<?xml version="1.0" encoding="UTF-8"?>';

?>

<Response>
<Dial record="true">
<Number>+18005558355</Number>
</Dial>
</Response>
