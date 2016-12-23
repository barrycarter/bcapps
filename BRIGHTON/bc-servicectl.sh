# list of services that can be disabled or masked safely


# disabling mariadb and postgresql here (though they may not have even
# started yet) because they dont start properly under systemctl --
# hack start in rc.local

systemctl disable auditd NetworkManager tuned cups wpa_supplicant irqbalance avahi-daemon vboxadd-service mariadb postgresql

systemctl mask gssproxy alsa-state
