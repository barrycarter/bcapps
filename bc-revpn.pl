#!/bin/perl

# reconnect to a random nordVPN (can't quite get this working as an alias)

# random server (UDP US)

my($server) = `ls /etc/openvpn/surfshark/us*.prod.surfshark.com_udp.ovpn | sort -R | head -1`;
chomp($server);

print STDERR $server;

system("sudo cp -f /home/user/BCGIT/BRIGHTON/resolv.conf.surfshark /etc/resolv.conf; sudo pkill openvpn; sudo openvpn --log-append /home/user/log/surfshark.log --config $server --config /home/user/BCGIT/BRIGHTON/bc-openvpn.cfg --auth-nocache --auth-user-pass /home/user/BCPRIV/surfshark.txt&");
