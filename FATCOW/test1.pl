#!/usr/bin/perl

# EX: ncftpput -u username -p password ftp.fatcow.com . test1.pl

print "Content-type: text/plain\n\n";

system("ls -l /usr/bin /bin");

