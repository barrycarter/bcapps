# remove stuff I dont want

sudo yum remove audit NetworkManager postfix irqbalance tuned

# TODO: downloads RPMs to /root/build unless they are already there
# (ie, for repos)

# link repos to yum.repos.d

sudo ln -s /home/user/BCGIT/CENTOS/*.repo /etc/yum.repos.d/

# install repos in /root/build

cd /root/build/
rpm -i nux-dextop-release-0-5.el7.nux.noarch.rpm ius-release.rpm gf-release-7-10.gf.el7.noarch.rpm

# and other useful symlinks

# let's me be "user" but still "be" barrycarter at the same time

sudo ln -s /home/user /home/barrycarter

# if you're using an older .fvwm2rc, this may help -- if not, it
# doesn't hurt (also for some of my programs that use direct paths)

sudo mkdir -p /usr/lib/X11 /usr/X11R6/
sudo ln -s /usr/libexec/fvwm/2.6.6 /usr/lib/X11/fvwm2
sudo ln -s /bin /usr/X11R6/

# my bclib.pl
sudo ln -s /home/barrycarter/BCGIT/bclib.pl /usr/local/lib/

sudo ln -s /home/user/BCGIT/CENTOS/.xinitrc /home/user/BCGIT/CENTOS/brighton-procs.txt /home/user

# others on a case to case basis

# bootstrap the user crontab process

sudo crontab -u user /home/user/BCGIT/FEDORA/bc-public-crontab

# mass install

# TODO: reach final decision over installing perl modules this way or
# from cpan or a combination like I'm doing now

sudo yum -y install epel-release ImageMagick OpenThreads PySolFC SDL-devel alpine aspell audacity bind c++-gtk-utils-gtk2-devel community-mysql community-mysql-server dosbox dosemu elinks emacs enscript esniper expect feh ffmpeg ftp fuse-encfs fvwm gd-devel getmail glade glade-devel gnumeric gnuplot gpm graphviz gtk+extra-devel gtk2-devel gtk3-devel html2ps lynx mencoder parallel mplayer mrtg nagios-plugins nano ncftp openrdate perl-CPAN php-mysqlnd pidgin postgresql postgresql-server qgis qhull rdesktop recoll rsyslog rxvt samba screen snownews stella stellarium tcsh tigervnc tk unrtf util-linux-user vice vlc xdotool xemacs xemacs-packages-extra-el xinetd xorg-x11-server-Xorg xorg-x11-apps xpdf xsane xteddy xterm xv yum yum-utils zlib-devel zlib-static mod_ldap tor tor-arm-gui tor-arm onionshare privoxy recordmydesktop tmpwatch esmtp-local-delivery sendmail sendmail-cf fuse-sshfs fuse-zip fuse-encfs curlftpfs bindfs xcalc libpuzzle libpuzzle-devel pyephem python2-astropy python3-astropy erfa libnova ast R sagemath-notebook nmap p7zip "perl-Digest-*" "perl-Date-*" "perl-DateTime-*" "perl-Text-*" "perl-MIME-*" "perl-Math-*" "perl-Data-*" "perl-JSON-*" "perl-Algorithm-*" "perl-DBI-*" "perl-DB_File" "perl-File-*" "perl-Net-*" "perl-Number-*" "perl-Getopt-*" "perl-GD" "perl-HTML-*" "perl-HTTP-*" "perl-IO-*" lucene "perl-LWP-*" "perl-Inline" "perl-Inline-*" perl-OpenGL perl-utf8-all "perl-B-*" "perl-IPC-*" perl-Imager "perl-Flickr-*" ntpdate

# upgrade all installed packages including new ones

sudo yum -y upgrade

# this installs cpan stuff (env var minimizes prompts)

PERL_MM_USE_DEFAULT=1

# confirm these are not available through centos first

# sudo cpan Statistics::Distributions Astro::Nova Astro::MoonPhase


