# list of services that can be disabled or masked safely

# entire command below fails if any of below fail (vboxadd-service
# only exists after VirtualBox is installed: if you run below w/o it,
# you get "Failed to execute operation: No such file or directory" and
# the entire command appears to fail

# TODO: consider turning these off one at a time which solves above
# problem and seems cleaner + can redirect output if needed

systemctl disable auditd NetworkManager tuned cups wpa_supplicant irqbalance avahi-daemon vboxadd-service rpc-statd.service rpcbind.service abrt

# TODO: this is temporary until I set up email correctly
systemctl disable sendmail

systemctl mask gssproxy alsa-state

# and ones I want that arent default

systemctl enable dnsmasq httpd


