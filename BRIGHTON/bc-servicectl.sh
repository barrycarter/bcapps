# list of services that can be disabled or masked safely

# entire command below fails if any of below fail (vboxadd-service
# only exists after VirtualBox is installed: if you run below w/o it,
# you get "Failed to execute operation: No such file or directory" and
# the entire command appears to fail

# TODO: perl loop for below (so I can stop and disable and log)?
# NOTE: I realize I can do this w/ tcsh/(ba)sh scripting, but hate those

# TODO: sendmail below is temporary until I set up email correctly

# TODO: actually exec these, don't just print them out

perl -le 'for $i ("firewalld", "nfs-mountd", "nfs-idmapd", "libvirtd", "ksmtuned", "libstoragemgmt", "rc-local.service", "systemd-ask-password-wall", "ModemMananger", "upower", "rngd", "smartd", "chronyd", "auditd", "NetworkManager", "tuned", "cups", "wpa_supplicant", "irqbalance", "avahi-daemon", "vboxadd-service", "rpc-statd.service", "rpcbind.service", "abrt-oops", "abrtd", "abrt-xorg", "sendmail") {print "systemctl stop $i | tee /tmp/stop-service-$i.log;\nsystemctl disable $i | tee /tmp/disable-service-$i.log"}' | sh



systemctl mask gssproxy 
systemctl mask alsa-state

# and ones I want that arent default

systemctl enable dnsmasq
systemctl enable httpd
systemctl enable tor
