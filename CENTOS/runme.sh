# remove stuff I dont want

# TODO: this apparently breaks stuff, so do it later or something
# sudo yum -y remove audit postfix

# edit SELINUX to disabled and keep cache for yum

printf '1,$s/keepcache=0/keepcache=1/\nwq\n' | ex /etc/yum.conf 
printf '1,$s/SELINUX=enforcing/SELINUX=disabled/\nwq\n'|ex /etc/selinux/config

# install rpmfusion repo (the only one I think I really really need)
# below cut/paste from https://rpmfusion.org/Configuration

su -c 'yum -y localinstall --nogpgcheck https://download1.rpmfusion.org/free/el/updates/6/i386/rpmfusion-free-release-6-1.noarch.rpm https://download1.rpmfusion.org/nonfree/el/updates/6/i386/rpmfusion-nonfree-release-6-1.noarch.rpm'

# also allowing linuxtech for vlc and such

sudo ln -s /home/user/BCGIT/CENTOS/linuxtech.repo /etc/yum.repos.d/

# installing epel here since its a repo
sudo yum -y install epel-release

# lets me be barrycarter and user at same time
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

# mass install

# TODO: reach final decision over installing perl modules this way or
# from cpan or a combination like I'm doing now

# TODO: right now using ONLY epel-release as my "extra" repo (and rpmfusion as above)

# the --skip-broken ensures yum doesnt stop but it also means some
# packages are skipped -- as noted in README, look at /runme.err on
# completion

sudo yum -y --skip-broken install wget efibootmgr firefox ImageMagick PySolFC alpine aspell audacity mysql mysql-server dosbox dosemu elinks emacs enscript esniper expect feh ftp fuse-encfs fvwm getmail gnumeric gnuplot gpm graphviz html2ps lynx mencoder parallel mplayer mrtg nagios-plugins nano ncftp rdate perl-CPAN pidgin postgresql postgresql-server qgis qhull rdesktop recoll rsyslog rxvt samba screen snownews stella stellarium tcsh tigervnc tk unrtf util-linux vice vlc xdotool xemacs xemacs-packages-extra-el xinetd xorg-x11-server-Xorg xorg-x11-apps xpdf xsane xteddy xterm xv yum yum-utils zlib-devel zlib-static tor onionshare privoxy recordmydesktop tmpwatch esmtp-local-delivery sendmail sendmail-cf fuse-sshfs fuse-zip fuse-encfs curlftpfs bindfs xcalc libpuzzle libpuzzle-devel pyephem python2-astropy python3-astropy erfa libnova ast R sagemath-notebook nmap p7zip "perl-Digest-*" "perl-Date-*" "perl-DateTime-*" "perl-Text-*" "perl-MIME-*" "perl-Math-*" "perl-Data-*" "perl-JSON-*" "perl-Algorithm-*" "perl-DBI-*" "perl-DB_File" "perl-File-*" "perl-Net-*" "perl-Number-*" "perl-Getopt-*" "perl-GD" "perl-HTML-*" "perl-HTTP-*" "perl-IO-*" lucene "perl-LWP-*" "perl-Inline" "perl-Inline-*" perl-OpenGL perl-utf8-all "perl-B-*" "perl-IPC-*" perl-Imager "perl-Flickr-*" ntpdate man crontab x11vnc tigervnc-server telnet

# fixes double ffmpeg-libs issue
yum remove ffmpeg ffmpeg-libs ffmpeg-libs_1.1
yum install ffmpeg-0.10.15 ffmpeg-libs-0.10.15
yum install vlc

# TODO: figure out Perl stuff I need

# this installs cpan stuff (env var minimizes prompts)

PERL_MM_USE_DEFAULT=1

# confirm these are not available through centos first

# sudo cpan Statistics::Distributions Astro::Nova Astro::MoonPhase

# TODO: use chkconfig now
# TODO: why does mysqld NOT work even after I install mariadb? (and nagios)
# sudo systemctl enable postgresql dnsmasq httpd sendmail
# sudo systemctl start postgresql dnsmasq httpd sendmail

# bootstrap the user crontab process

sudo crontab -u user /home/user/BCGIT/FEDORA/bc-public-crontab

