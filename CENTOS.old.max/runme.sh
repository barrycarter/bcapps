# note that "yum install '*'" is a terrible idea and breaks things

# below is a copy of FEDORA/runme.sh

# sudo dnf -y install --allowerasing --best ImageMagick OpenThreads PySolFC SDL-devel alpine aspell audacity bind c++-gtk-utils-gtk2-devel community-mysql community-mysql-server dosbox dosemu elinks emacs enscript esniper expect feh ffmpeg ftp fuse-encfs fvwm gd gd-devel getmail glade glade-devel glib2 gnumeric gnuplot gpm graphviz gtk+extra-devel gtk2 gtk2-devel gtk3-devel html2ps lynx mencoder moreutils-parallel mplayer mrtg nagios nagios-plugins nano ncftp openrdate perl-CPAN php-mysqlnd pidgin postgresql postgresql-server qgis qhull rdesktop recoll rsyslog rxvt samba screen snownews stella stellarium tcsh tigervnc tk unrtf util-linux-user vice vino vlc xdotool xemacs xemacs-packages-extra-el xinetd xorg-x11-apps xpdf xsane xteddy xterm xv yum yum-utils zlib zlib-devel zlib-static mod_ldap mod_dnssd tor tor-arm-gui tor-arm onionshare privoxy celestia recordmydesktop tmpwatch esmtp-local-delivery sendmail sendmail-cf fuse-sshfs fuse-zip fuse-encfs curlftpfs bindfs xcalc libpuzzle libpuzzle-devel pyephem python2-astropy python3-astropy erfa libnova ast R sagemath-notebook nmap p7zip words evince

# below is my pruned version; although I only install stuff I want, many other things are installed as dependencies

sudo yum -y install ImageMagick PySolFC alpine aspell community-mysql community-mysql-server dosbox dosemu elinks emacs enscript esniper expect feh ffmpeg ftp fuse-encfs fvwm getmail gnumeric gnuplot gpm graphviz html2ps lynx mencoder moreutils-parallel mplayer mrtg nagios nagios-plugins nano ncftp openrdate perl-CPAN php-mysqlnd pidgin postgresql postgresql-server qgis qhull rdesktop recoll rsyslog rxvt samba screen snownews stella stellarium tcsh tigervnc tk unrtf vice vino vlc xdotool xemacs xemacs-packages-extra-el xinetd xorg-x11-apps xpdf xsane xteddy xterm xv zlib tor onionshare privoxy celestia recordmydesktop tmpwatch esmtp-local-delivery sendmail sendmail-cf fuse-sshfs fuse-zip curlftpfs bindfs xcalc pyephem python2-astropy python3-astropy erfa libnova ast R sagemath-notebook nmap p7zip words evince rsync xorg-x11-xinit xorg-x11-server-Xorg

# CPAN stuff copied over directly from fedora

PERL_MM_USE_DEFAULT=1

sudo cpan Digest::SHA1 Digest::MD5 Date::Parse POSIX Text::Unidecode Test MIME::Base64 utf8 Statistics::Distributions Math::Round Data::Dumper B Astro::Nova Astro::MoonPhase JSON Algorithm::GoldenSection Astro::Coord::ECI::Moon Astro::Time DBI DB_File Data::Dumper Data::Faker Date::Manip Date::Parse Digest::HMAC_SHA1 Digest::SHA FFI::Raw Fcntl File::Temp Flickr::API GD Getopt::Long Getopt::Std HTML::TreeBuilder::XPath HTTP::Date IO::File IPC::Open3 Imager::QRCode Inline::Python LWP::UserAgent Math::BigInt Math::Round Math::Polygon::Calc Math::ematica Net::Amazon::MechanicalTurk Net::DNS::Nameserver Net::LDAP Number::Spell OpenGL Pg Plucene::Analysis::SimpleAnalyzer Plucene::Document::Field Plucene::Document Plucene

# we don't turn off any services since CentOS starts pretty bare

sudo systemctl enable postgresql mysqld nagios dnsmasq httpd sendmail

sudo systemctl start postgresql mysqld nagios dnsmasq httpd sendmail

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

# TODO: check if vino works "as is"; if not, copy settings from FEDORA/runme.sh

# allow all wheel users to become root passwordlessly (necessary for
# many things later)

echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel



