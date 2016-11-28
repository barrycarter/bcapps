# for debugging what exactly is breaking cryptsetup at boot

# this by-hand command helps if I destroy too many other things

# systemctl list-unit-files|grep masked|perl -anle 'print "systemctl
# unmask $F[0]\nsystemctl enable $F[0]"'

# final version of what can actually be stopped

sudo systemctl stop abrtd abrt-oops abrt-ccpp.service abrt-vmcore.service abrt-xorg avahi-daemon chronyd firewalld mcelog ModemManager rngd systemd-journald avahi-daemon.socket systemd-journald.socket systemd-journald-audit.socket systemd-journald-dev-log.socket udisks2

sudo systemctl mask abrtd abrt-oops abrt-ccpp.service abrt-vmcore.service abrt-xorg avahi-daemon chronyd firewalld mcelog ModemManager rngd systemd-journald avahi-daemon.socket systemd-journald.socket systemd-journald-audit.socket systemd-journald-dev-log.socket udisks2


exit;


sudo systemctl stop abrtd abrt-oops abrt-ccpp.service abrt-vmcore.service abrt-xorg avahi-daemon chronyd firewalld mcelog ModemManager rngd systemd-journald avahi-daemon.socket systemd-journald.socket systemd-journald-audit.socket systemd-journald-dev-log.socket

sudo systemctl mask abrtd abrt-oops abrt-ccpp.service abrt-vmcore.service abrt-xorg avahi-daemon chronyd firewalld mcelog ModemManager rngd systemd-journald avahi-daemon.socket systemd-journald.socket systemd-journald-audit.socket systemd-journald-dev-log.socket

exit;

# as of 20161121.114159, confirmed the above does not break reoot; now
# trying a few more things MANUALLY

# the below WILL break reboot
# sudo systemctl stop systemd-logind
# sudo systemctl mask systemd-logind

# the below WILL break reboot (not bothering to figure out which one)
# sudo systemctl stop systemd-udevd systemd-udevd-control systemd-udevd-kernel
# sudo systemctl mask systemd-udevd systemd-udevd-control systemd-udevd-kernel

# the below will NOT break reboot
sudo systemctl stop udisks2
sudo systemctl mask udisks2




# this command should work -- only systemd-logind has been restored
# from what I masked/etc earlier

sudo systemctl stop abrtd abrt-oops abrt-ccpp.service abrt-vmcore.service abrt-xorg avahi-daemon chronyd firewalld mcelog ModemManager NetworkManager-dispatcher rngd systemd-journald avahi-daemon.socket rngd systemd-journald avahi-daemon.socket systemd-journald.socket systemd-journald-audit.socket systemd-journald-dev-log.socket

sudo systemctl mask abrtd abrt-oops abrt-ccpp.service abrt-vmcore.service abrt-xorg avahi-daemon chronyd firewalld mcelog ModemManager NetworkManager-dispatcher rngd systemd-journald avahi-daemon.socket rngd systemd-journald avahi-daemon.socket systemd-journald.socket systemd-journald-audit.socket systemd-journald-dev-log.socket

exit;

sudo systemctl stop    abrtd abrt-oops abrt-ccpp.service abrt-vmcore.service abrt-xorg avahi-daemon chronyd firewalld mcelog ModemManager avahi-daemon.socket

sudo systemctl mask    abrtd abrt-oops abrt-ccpp.service abrt-vmcore.service abrt-xorg avahi-daemon chronyd firewalld mcelog ModemManager avahi-daemon.socket

# note the above does NOT break things when restarting

# <broke things>

# sudo systemctl stop rngd systemd-logind systemd-journald avahi-daemon.socket systemd-journald.socket systemd-journald-audit.socket systemd-journald-dev-log.socket

# sudo systemctl mask rngd systemd-logind systemd-journald avahi-daemon.socket systemd-journald.socket systemd-journald-audit.socket systemd-journald-dev-log.socket

# </broke things>

sudo systemctl unmask systemd-logind
sudo systemctl enable systemd-logind
sudo systemctl start systemd-logind

sudo systemctl stop rngd systemd-journald avahi-daemon.socket systemd-journald.socket systemd-journald-audit.socket systemd-journald-dev-log.socket

sudo systemctl mask rngd systemd-journald avahi-daemon.socket systemd-journald.socket systemd-journald-audit.socket systemd-journald-dev-log.socket

exit ; 

sudo systemctl stop    abrtd abrt-oops abrt-ccpp.service abrt-vmcore.service abrt-xorg avahi-daemon chronyd firewalld mcelog ModemManager NetworkManager-dispatcher rngd systemd-logind systemd-journald avahi-daemon.socket systemd-journald.socket systemd-journald-audit.socket systemd-journald-dev-log.socket

sudo systemctl mask    abrtd abrt-oops abrt-ccpp.service abrt-vmcore.service abrt-xorg avahi-daemon chronyd firewalld mcelog ModemManager NetworkManager-dispatcher rngd systemd-logind systemd-journald avahi-daemon.socket systemd-journald.socket systemd-journald-audit.socket systemd-journald-dev-log.socket

sudo systemctl unmask    abrtd abrt-oops abrt-ccpp.service abrt-vmcore.service abrt-xorg avahi-daemon chronyd firewalld mcelog ModemManager NetworkManager-dispatcher rngd systemd-logind systemd-journald avahi-daemon.socket systemd-journald.socket systemd-journald-audit.socket systemd-journald-dev-log.socket

sudo systemctl enable    abrtd abrt-oops abrt-ccpp.service abrt-vmcore.service abrt-xorg avahi-daemon chronyd firewalld mcelog ModemManager NetworkManager-dispatcher rngd systemd-logind systemd-journald avahi-daemon.socket systemd-journald.socket systemd-journald-audit.socket systemd-journald-dev-log.socket

sudo systemctl start    abrtd abrt-oops abrt-ccpp.service abrt-vmcore.service abrt-xorg avahi-daemon chronyd firewalld mcelog ModemManager NetworkManager-dispatcher rngd systemd-logind systemd-journald avahi-daemon.socket systemd-journald.socket systemd-journald-audit.socket systemd-journald-dev-log.socket
