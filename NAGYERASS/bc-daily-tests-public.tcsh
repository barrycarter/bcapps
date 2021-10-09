# The ": << HERE" format is not really for multiline comments, but it works

: << HEADER

A list of tests I am making public on the off chance they might help
someone

HEADER

: << PASSWORD

My pw.txt holds my passwords and the first field represents where the
password is used (except for empty lines, comments, lines starting
with the marker "OBSOLETE"). It must be one of the following:

  - A domain name ending in an approved prefix (but possibly followed by other nonalphabetic characters, such https://example.com/path)

  - The psuedo domain name .lan for local machines

  - an IP address potentially followed by colon and a port number (for
  MUSHes and MOOs and MUDs and MUCKs and such-- I have passwords
  dating back to the early 90s though I'm not sure how many of them
  still work)

  - a string that starts with a quotation mark or bracket, meaning the password usage location is described in text and not a website

The last part of the pipe confirms there are no results (ie, no non-compliant strings)

PASSWORD

egrep -v '^$|^#|^OBSOLETE:' ~/pw.txt | perl -anle 'unless ($F[0]=~m/\.(com|net|gov|org|tv|io|edu|us|it|de|hu|uk|biz|fm|to|se|ch|im|ca|co|info|lan|club|space)(\W|$)/ || $F[0]=~m/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(:\d{1,5})?/ || $F[0]=~/\"|\[/) {print $_}' | perl -nle 'if (length($_)>=0) {print "STDIN NOT EMPTY"; exit 2;} else {exit 0;}' 








