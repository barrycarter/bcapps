all: hostfreq.txt ipfreq.txt resolvedhosts.txt codelist.txt codes-by-big-cities.txt
sortedhosts.txt: samplehosts4.txt
	reverse-hosts.pl
sortedips.txt: samplehosts4.txt
	reverse-hosts.pl
hostfreq.txt: sortedhosts.txt
	bc-most-freq.pl
ipfreq.txt: sortedips.txt
	bc-most-freq-ip.pl
resolvedhosts.txt: sortedhosts.txt regexps.txt
	bc-geolocate.pl --debug
codelist.txt: sortedhosts.txt regexps.txt
	bc-geolocate.pl --debug
codes-by-big-cities.txt: codelist.txt
	bc-find-us-code.pl
