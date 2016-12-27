# list of services that can be disabled or masked safely

systemctl disable auditd NetworkManager tuned cups wpa_supplicant irqbalance avahi-daemon vboxadd-service

systemctl mask gssproxy alsa-state

# and ones I want that arent default

systemctl enable dnsmasq httpd


