all: hostfreq.txt ipfreq.txt
sortedhosts.txt: samplehosts4.txt
	reverse-hosts.pl
sortedips.txt: samplehosts4.txt
	reverse-hosts.pl
hostfreq.txt: sortedhosts.txt
	bc-most-freq.pl
ipfreq.txt: sortedips.txt
	bc-most-freq-ip.pl
