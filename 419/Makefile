# confirmed scammers from leonard.zeptowitz.has.replied
confirmed2.txt: /mnt/sshfs/MAIL/leonard.zeptowitz.has.replied.FINAL bc-has-replied.pl Makefile
	bc-has-replied.pl
# glue the temp mailbox to the end of the permanent one
# the FINAL file is on /mnt/sshfs, the nonfinal file is on local HD
# sleep 1 below is because sshfs doesnt appear to handle fractional seconds
/mnt/sshfs/MAIL/leonard.zeptowitz.has.replied.FINAL: /home/barrycarter/mail/leonard.zeptowitz.has.replied
	cat /home/barrycarter/mail/leonard.zeptowitz.has.replied >> /mnt/sshfs/MAIL/leonard.zeptowitz.has.replied.FINAL; rm /home/barrycarter/mail/leonard.zeptowitz.has.replied; touch /home/barrycarter/mail/leonard.zeptowitz.has.replied; sleep 1; touch /mnt/sshfs/MAIL/leonard.zeptowitz.has.replied.FINAL
