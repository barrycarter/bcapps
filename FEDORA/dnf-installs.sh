: dnf isnt quite smart enough to install both a repo and packages at
: the same time, alas

sudo dnf install --allowerasing --best http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

sudo dnf install --allowerasing --best ImageMagick OpenThreads PySolFC SDL-devel alpine aspell audacity bind c++-gtk-utils-gtk2-devel community-mysql community-mysql-server dosbox dosemu elinks emacs enscript esniper expect feh ffmpeg ftp fuse-encfs fvwm gd gd-devel getmail glade glade-devel glib2 gnumeric gnuplot gpm graphviz gtk+extra-devel gtk2 gtk2-devel gtk3-devel html2ps lynx mencoder moreutils-parallel mplayer mrtg nagios nagios-plugins nano ncftp openrdate perl-CPAN php-mysqlnd pidgin postgresql postgresql-server qgis qhull rdesktop recoll rsyslog rxvt samba screen snownews stella stellarium tcsh tigervnc tk unrtf util-linux-user vice vino vlc xdotool xemacs xemacs-packages-extra-el xinetd xorg-x11-apps xpdf xsane xteddy xterm xv yum yum-utils zlib zlib-devel zlib-static mod_ldap mod_dnssd tor tor-arm-gui tor-arm onionshare privoxy celestia p7zip


