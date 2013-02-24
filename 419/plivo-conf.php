<?php

  // if you call a number that goes to this script, you enter conference "419"
  // this is the "answer_url" for conferencing in other people

header("Content-type: application/xml"); 
echo '<?xml version="1.0" encoding="UTF-8"?>';

?>

<Response><Conference record='true'>419</Conference></Response>
