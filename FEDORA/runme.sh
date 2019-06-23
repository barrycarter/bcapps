#!/usr/bin/sh -x

# this installs a couple of repos (dnf can't quite install repos and
# programs at the same time, alas)


sudo dnf -y install --allowerasing --best http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# and this installs a bunch more stuff

# TODO: restore "celestia" to this list once I figure out how to install it after removing gvfs

# NOTE: do NOT install moreutils-parallel -- it is a conflicting and
# broken version of the "real" parallel

sudo dnf -y install --allowerasing --best ImageMagick OpenThreads PySolFC SDL-devel alpine aspell audacity bind c++-gtk-utils-gtk2-devel community-mysql community-mysql-server dosbox dosemu elinks emacs enscript esniper expect feh ffmpeg ftp fuse-encfs fvwm gd-devel getmail glade glade-devel gnumeric gnuplot gpm graphviz gtk+extra-devel gtk2-devel gtk3-devel html2ps lynx mencoder parallel mplayer mrtg nagios-plugins nano ncftp openrdate perl-CPAN php-mysqlnd pidgin postgresql postgresql-server qgis qhull rdesktop recoll rsyslog rxvt samba screen snownews stella stellarium tcsh tigervnc tk unrtf util-linux-user vice vlc xdotool xemacs xemacs-packages-extra-el xinetd xorg-x11-apps xpdf xsane xteddy xterm xv yum yum-utils zlib-devel zlib-static mod_ldap tor tor-arm-gui tor-arm onionshare privoxy recordmydesktop tmpwatch esmtp-local-delivery sendmail sendmail-cf fuse-sshfs fuse-zip fuse-encfs curlftpfs bindfs xcalc libpuzzle libpuzzle-devel pyephem python2-astropy python3-astropy erfa libnova ast R sagemath-notebook nmap p7zip "perl-Digest-*" "perl-Date-*" "perl-DateTime-*" "perl-Text-*" "perl-MIME-*" "perl-Math-*" "perl-Data-*" "perl-JSON-*" "perl-Algorithm-*" "perl-DBI-*" "perl-DB_File" "perl-File-*" "perl-Net-*" "perl-Number-*" "perl-Getopt-*" "perl-GD" "perl-HTML-*" "perl-HTTP-*" "perl-IO-*" lucene "perl-LWP-*" "perl-Inline" "perl-Inline-*" perl-OpenGL perl-utf8-all "perl-B-*" "perl-IPC-*" perl-Imager "perl-Flickr-*" ntpdate

# because I installed from 7GB download, still need to check online
# for upgrades

sudo dnf -y upgrade

# this is fairly safe, it shouldn't kill anything installed above
sudo dnf -y remove gvfs "gvfs-*" gnome-keyring

# this installs cpan stuff (env var minimizes prompts)

PERL_MM_USE_DEFAULT=1

# confirmed these are not available through fedora 24 repo

sudo cpan Statistics::Distributions Astro::Nova Astro::MoonPhase


# TODO: add Math::ematica back in after I install it

# TODO: add Net::Amazon::MechanicalTurk back in after I figure out why
# its broken (however, their protocol has changed a lot)

# NOTE: commenting all this out for now, and will add modules as needed if Fedora 24 repo doesn't have them

# sudo cpan Test POSIX Statistics::Distributions Astro::Nova Astro::MoonPhase Astro::Coord::ECI::Moon Astro::Time FFI::Raw Fcntl

# for systemctl, we go in reverse order: enable ones we want and THEN
# disable ones we dont

sudo systemctl enable postgresql mysqld nagios dnsmasq httpd sendmail

# debugging tips:

# to see what services restart at reboot, try this extreme:

# systemctl -t service|grep 'loaded active running'| perl -anle 'print "systemctl stop $F[0]; systemctl disable $F[0]"' | sh

# and then:
# systemctl stop dbus.socket lvm2-lvmetad.socket
# systemctl disable dbus.socket lvm2-lvmetad.socket

# after above, "auditd" comes up immediately (in fact, you cant stop it)

# TODO: one of these appears to require disk encryption pw for some reason?!
# sudo systemctl start postgresql mysqld nagios dnsmasq httpd sendmail

# below breaks
# sudo systemctl start postgresql mysqld nagios

# below breaks
# sudo systemctl start dnsmasq httpd sendmail

# fails: postgresql mysqld  nagios dnsmasq httpd sendmail

# disable and stop unneeded services

# note systemd-udevd is important, can't kill it (and its various
# sockets/etc) and so it systemd-logind

sudo systemctl stop    abrtd abrt-oops abrt-ccpp.service abrt-vmcore.service abrt-xorg avahi-daemon chronyd firewalld mcelog ModemManager rngd systemd-journald avahi-daemon.socket systemd-journald.socket systemd-journald-audit.socket systemd-journald-dev-log.socket udisks2 accounts-daemon colord gdm gssproxy libvirtd lvm2-lvmetad lvm2-lvmetad.socket packagekit upower wpa_supplicant rtkit-daemon gssproxy auditd cups bluetooth NetworkManager

sudo systemctl disable abrtd abrt-oops abrt-ccpp.service abrt-vmcore.service abrt-xorg avahi-daemon chronyd firewalld mcelog ModemManager rngd systemd-journald avahi-daemon.socket systemd-journald.socket systemd-journald-audit.socket systemd-journald-dev-log.socket udisks2 accounts-daemon colord gdm gssproxy libvirtd lvm2-lvmetad lvm2-lvmetad.socket packagekit upower wpa_supplicant rtkit-daemon gssproxy auditd cups bluetooth NetworkManager

# useful symlinks

# TODO: for all symlinks, worry if symlink already exists?

# TODO: maybe write program that checks symlink, ignores if exists
# with right value, complains is file exists and is not a symlink or
# wrong symlink

# let's me be "user" but still "be" barrycarter at the same time

sudo ln -s /home/user /home/barrycarter

# if you're using an older .fvwm2rc, this may help -- if not, it
# doesn't hurt (also for some of my programs that use direct paths)

sudo mkdir -p /usr/lib/X11 /usr/X11R6/
sudo ln -s /usr/libexec/fvwm/2.6.6 /usr/lib/X11/fvwm2
sudo ln -s /bin /usr/X11R6/

# other helpful symlinks if you're using older software or programs
# that rely on a specific path (or my bclib.pl):

sudo ln -s /bin/php /usr/local/bin/
sudo ln -s /home/barrycarter/BCGIT/bclib.pl /usr/local/lib/

# symlinks of important files to BCGIT

sudo ln -s /home/user/BCGIT/FEDORA/.xinitrc /home/user/BCGIT/FEDORA/startup-nox.sh /home/user/BCGIT/FEDORA/startup-x.sh /home/user/BCGIT/FEDORA/brighton-procs.txt /home/user

# and some because I'm using older system

sudo ln -s /usr/share/dict /usr/

# directories my programs use and chown them to user

sudo mkdir -p /usr/local/etc/locks /usr/local/etc/registry /var/tmp/montastic
sudo chown -R user /usr/local/etc /var/tmp/
sudo mkdir -p /var/nagios/

# and IP/DNS fixups

rm /etc/sysconfig/network-scripts/ifcfg-enp1s0
ln -s /home/user/BCGIT/FEDORA/ifcfg-enp1s0 /etc/sysconfig/network-scripts/
rm /etc/resolv.conf
ln -s /home/user/BCGIT/FEDORA/resolv.conf /etc/

# TODO: consider mirroring /usr/local/etc/ once I confirm its all my
# stuff (lynx and scowl seem to use it too)

# NOTE: do NOT try to disable (or remove the packages that contain)
# any of: "dbus", "lvm2-lvmetad", "polkit", "getty",
# "user@*.service". Doing so may break things severely.

# initialize postgres

sudo postgresql-setup --initdb

# this allows vnc access with the password 'abc123' even if your vnc
# viewer doesn't support encryption (you should change 'abc123' at
# some point)

sudo gsettings set org.gnome.Vino require-encryption false
sudo gsettings set org.gnome.Vino prompt-enabled false
sudo gsettings set org.gnome.Vino authentication-methods "['vnc']"
sudo gsettings set org.gnome.Vino vnc-password `echo -n "abc123"|base64`

# allow all wheel users to become root passwordlessly (necessary for
# many things later)

echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel

# bootstrap the user crontab process

sudo crontab -u user /home/user/BCGIT/FEDORA/bc-public-crontab

# putting these in main root might be dumb?
# note 'sh -c' required so sudo does entire command
sudo sh -c 'dnf list installed > /dnf-installed.txt'
sudo sh -c 'cpan -l > /cpan-installed.txt'
sudo sh -c 'systemctl > /systemctl-raw.txt'
sudo sh -c 'systemctl list-unit-files > /systemctl-list-unit-files.txt'
sudo sh -c 'ps -wwwef > /ps-wwwef.txt'
