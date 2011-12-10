<?php

$array = array(
	       "I miss you so much",
	       "I'm touching myself thinking about you",
	       "Please come back to me",
	       "You took something with you when you left: my heart"
	      );

$msg = $array[array_rand($array,1)];

?>




<Response><Sms>
<?php echo $msg; ?>
</Sms></Response>
