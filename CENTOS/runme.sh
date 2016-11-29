# remove stuff I dont want

sudo yum -y remove audit NetworkManager postfix irqbalance tuned

# edit SELINUX to disabled and keep cache for yum

printf '1,$s/keepcache=0/keepcache=1/\nwq\n' | ex /etc/yum.conf 
printf '1,$s/SELINUX=enforcing/SELINUX=disabled/\nwq\n'|ex /etc/selinux/config

# install rpmfusion repo (the only one I think I really really need)
# below cut/paste from https://rpmfusion.org/Configuration

su -c 'yum -y localinstall --nogpgcheck https://download1.rpmfusion.org/free/el/updates/6/i386/rpmfusion-free-release-6-1.noarch.rpm https://download1.rpmfusion.org/nonfree/el/updates/6/i386/rpmfusion-nonfree-release-6-1.noarch.rpm'

sudo ln -s /home/user /home/barrycarter

# if you're using an older .fvwm2rc, this may help -- if not, it
# doesn't hurt (also for some of my programs that use direct paths)

sudo mkdir -p /usr/lib/X11 /usr/X11R6/
sudo ln -s /usr/libexec/fvwm/2.6.6 /usr/lib/X11/fvwm2
sudo ln -s /bin /usr/X11R6/

# my bclib.pl
sudo ln -s /home/barrycarter/BCGIT/bclib.pl /usr/local/lib/

# and list of procs and xinitrc
sudo ln -s /home/user/BCGIT/CENTOS/.xinitrc /home/user/BCGIT/CENTOS/brighton-procs.txt /home/user

# others on a case to case basis

# bootstrap the user crontab process

sudo crontab -u user /home/user/BCGIT/FEDORA/bc-public-crontab

# mass install

# TODO: reach final decision over installing perl modules this way or
# from cpan or a combination like I'm doing now

# TODO: right now using ONLY epel-release as my "extra" repo (and rpmfusion as above)

# the --skip-broken ensures yum doesnt stop but it also means some
# packages are skipped -- as noted in README, look at /runme.err on
# completion

sudo yum -y --skip-broken install epel-release wget efibootmgr firefox ImageMagick OpenThreads PySolFC SDL-devel alpine aspell audacity bind c++-gtk-utils-gtk2-devel mariadb dosbox dosemu elinks emacs enscript esniper expect feh ffmpeg ftp fuse-encfs fvwm gd-devel getmail glade glade-devel gnumeric gnuplot gpm graphviz gtk+extra-devel gtk2-devel gtk3-devel html2ps lynx mencoder parallel mplayer mrtg nagios-plugins nano ncftp rdate perl-CPAN php-mysqlnd pidgin postgresql postgresql-server qgis qhull rdesktop recoll rsyslog rxvt samba screen snownews stella stellarium tcsh tigervnc tk unrtf util-linux vice vlc xdotool xemacs xemacs-packages-extra-el xinetd xorg-x11-server-Xorg xorg-x11-apps xpdf xsane xteddy xterm xv yum yum-utils zlib-devel zlib-static mod_ldap tor tor-arm-gui tor-arm onionshare privoxy recordmydesktop tmpwatch esmtp-local-delivery sendmail sendmail-cf fuse-sshfs fuse-zip fuse-encfs curlftpfs bindfs xcalc libpuzzle libpuzzle-devel pyephem python2-astropy python3-astropy erfa libnova ast R sagemath-notebook nmap p7zip "perl-Digest-*" "perl-Date-*" "perl-DateTime-*" "perl-Text-*" "perl-MIME-*" "perl-Math-*" "perl-Data-*" "perl-JSON-*" "perl-Algorithm-*" "perl-DBI-*" "perl-DB_File" "perl-File-*" "perl-Net-*" "perl-Number-*" "perl-Getopt-*" "perl-GD" "perl-HTML-*" "perl-HTTP-*" "perl-IO-*" lucene "perl-LWP-*" "perl-Inline" "perl-Inline-*" perl-OpenGL perl-utf8-all "perl-B-*" "perl-IPC-*" perl-Imager "perl-Flickr-*" ntpdate

# TODO: figure out Perl stuff I need

# this installs cpan stuff (env var minimizes prompts)

PERL_MM_USE_DEFAULT=1

# confirm these are not available through centos first

# sudo cpan Statistics::Distributions Astro::Nova Astro::MoonPhase

# TODO: why does mysqld NOT work even after I install mariadb? (and nagios)
sudo systemctl enable postgresql dnsmasq httpd sendmail
sudo systemctl start postgresql dnsmasq httpd sendmail

