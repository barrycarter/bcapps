# this is a sample bc-private.pl file

# to access a cPanel
$cpanel{user} = "barrycarter";
$cpanel{pass} = "my-cpanel-password";
# host where you're running cpanel
$cpanel{site} = "barrycarter.info";

$geonames{user} = "barrycarter";
$geonames{pass} = "my-geonames-password";

$wikia{user} = "barrycarter";
$wikia{pass} = "my-wikia-pw";

$wunderground{key} = "my-wunderground.com-key";

$supertweet{user} = "barrycarter";
$supertweet{pass} = "supertweet-pw-not-same-as-twitter-pw";

$twitter{user} = "barrycarter";
$twitter{pass} = "twitter-password";

# twitter regex that bc-stream-twitter ignores
@badtwitterregex= (
"fuck bitches|calls 911|sona2012|hungry dolphin|mathtutor01|^rt|new york city tutor|are you paying a private tutor for|75\% commission|vacation math|from little boys|kid call 911|800DollarsForAniPhone"
);

# twitter users that bc-stream-twitter ignores
@badtwitterusers = ("articletrove", "addinggames", "huntington_jobs");

