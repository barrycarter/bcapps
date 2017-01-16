# list of services that can be disabled or masked safely

systemctl disable auditd NetworkManager tuned cups wpa_supplicant irqbalance avahi-daemon vboxadd-service rpc-statd.service rpcbind.service

# TODO: this is temporary until I set up email correctly
systemctl disable sendmail

systemctl mask gssproxy alsa-state

# and ones I want that arent default

systemctl enable dnsmasq httpd


