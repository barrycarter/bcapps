# This dnf command removes pretty much everything that can safely be
# removed (you may see some harmless errors).

sudo dnf -y remove gssproxy alsa-utils 'gvfs*' rtkit "gnome*" "evolution*"

# TODO: cleanup the removes above and below; redundant

# this installs a couple of repos (dnf can't quite install repos and
# programs at the same time, alas)

sudo dnf -y install --allowerasing --best http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# and this installs a bunch more stuff (some of which restore some of
# the stuff we removed, but only a portion of it)

sudo dnf -y install --allowerasing --best ImageMagick OpenThreads PySolFC SDL-devel alpine aspell audacity bind c++-gtk-utils-gtk2-devel community-mysql community-mysql-server dosbox dosemu elinks emacs enscript esniper expect feh ffmpeg ftp fuse-encfs fvwm gd gd-devel getmail glade glade-devel glib2 gnumeric gnuplot gpm graphviz gtk+extra-devel gtk2 gtk2-devel gtk3-devel html2ps lynx mencoder moreutils-parallel mplayer mrtg nagios nagios-plugins nano ncftp openrdate perl-CPAN php-mysqlnd pidgin postgresql postgresql-server qgis qhull rdesktop recoll rsyslog rxvt samba screen snownews stella stellarium tcsh tigervnc tk unrtf util-linux-user vice vino vlc xdotool xemacs xemacs-packages-extra-el xinetd xorg-x11-apps xpdf xsane xteddy xterm xv yum yum-utils zlib zlib-devel zlib-static mod_ldap mod_dnssd tor tor-arm-gui tor-arm onionshare privoxy celestia recordmydesktop tmpwatch esmtp-local-delivery sendmail sendmail-cf fuse-sshfs fuse-zip fuse-encfs curlftpfs bindfs xcalc libpuzzle libpuzzle-devel pyephem python2-astropy python3-astropy erfa libnova ast R sagemath-notebook nmap p7zip words evince

# this installs cpan stuff (env var minimizes prompts)

PERL_MM_USE_DEFAULT=1

sudo cpan Digest::SHA1 Digest::MD5 Date::Parse POSIX Text::Unidecode Test MIME::Base64 utf8 Statistics::Distributions Math::Round Data::Dumper B Astro::Nova Astro::MoonPhase JSON Algorithm::GoldenSection Astro::Coord::ECI::Moon Astro::Time DBI DB_File Data::Dumper Data::Faker Date::Manip Date::Parse Digest::HMAC_SHA1 Digest::SHA FFI::Raw Fcntl File::Temp Flickr::API GD Getopt::Long Getopt::Std HTML::TreeBuilder::XPath HTTP::Date IO::File IPC::Open3 Imager::QRCode Inline::Python LWP::UserAgent Math::BigInt Math::Round Math::Polygon::Calc Math::ematica Net::Amazon::MechanicalTurk Net::DNS::Nameserver Net::LDAP Number::Spell OpenGL Pg Plucene::Analysis::SimpleAnalyzer Plucene::Document::Field Plucene::Document Plucene

# for systemctl, we go in reverse order: enable ones we want and THEN
# disable ones we dont

sudo systemctl enable postgresql mysqld nagios dnsmasq httpd sendmail

sudo systemctl start postgresql mysqld nagios dnsmasq httpd sendmail

# disable and stop unneeded services

# note systemd-udevd is important, can't kill it (and its various
# sockets/etc) and so it systemd-logind

sudo systemctl stop abrtd abrt-oops abrt-ccpp.service abrt-vmcore.service abrt-xorg avahi-daemon chronyd firewalld mcelog ModemManager rngd systemd-journald avahi-daemon.socket systemd-journald.socket systemd-journald-audit.socket systemd-journald-dev-log.socket udisks2

sudo systemctl mask abrtd abrt-oops abrt-ccpp.service abrt-vmcore.service abrt-xorg avahi-daemon chronyd firewalld mcelog ModemManager rngd systemd-journald avahi-daemon.socket systemd-journald.socket systemd-journald-audit.socket systemd-journald-dev-log.socket udisks2

# useful symlinks

# TODO: for all symlinks, worry if symlink already exists?

# TODO: maybe write program that checks symlink, ignores if exists
# with right value, complains is file exists and is not a symlink or
# wrong symlink

# let's me be "user" but still "be" barrycarter at the same time

sudo ln -s /home/user /home/barrycarter

# if you're using an older .fvwm2rc, this may help -- if not, it
# doesn't hurt

sudo mkdir -p /usr/lib/X11
sudo ln -s /usr/libexec/fvwm/2.6.6 /usr/lib/X11/fvwm2

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
