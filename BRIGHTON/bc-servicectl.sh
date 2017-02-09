# list of services that can be disabled or masked safely

# entire command below fails if any of below fail (vboxadd-service
# only exists after VirtualBox is installed: if you run below w/o it,
# you get "Failed to execute operation: No such file or directory" and
# the entire command appears to fail

# TODO: perl loop for below (so I can stop and disable and log)?

systemctl disable auditd
systemctl disable NetworkManager
systemctl disable tuned
systemctl disable cups
systemctl disable wpa_supplicant
systemctl disable irqbalance
systemctl disable avahi-daemon
systemctl disable vboxadd-service
systemctl disable rpc-statd.service
systemctl disable rpcbind.service
systemctl disable abrt-oops
systemctl disable abrtd
systemctl disable abrt-xorg


# TODO: this is temporary until I set up email correctly
systemctl disable sendmail

systemctl mask gssproxy 
systemctl mask alsa-state

# and ones I want that arent default

systemctl enable dnsmasq 
systemctl enable httpd
