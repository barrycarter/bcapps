#!/bin/perl

# reconnect to a random nordVPN (can't quite get this working as an alias)

# random server (UDP US)

my($server) = `ls /etc/openvpn/server/ovpn_udp/us* | sort -R | head -1`;
chomp($server);

print STDERR $server;

system("sudo cp -f /etc/resolv.conf.nordvpn /etc/resolv.conf; sudo pkill openvpn; sudo openvpn --config $server --config /home/user/BCGIT/BRIGHTON/bc-openvpn.cfg --auth-nocache --auth-user-pass /home/user/BCPRIV/nordvpn.txt&");
