# remove stuff I dont want

# TODO: this apparently breaks stuff, so do it later or something
# sudo yum -y remove audit postfix

# the --skip-broken ensures yum doesnt stop but it also means some
# packages are skipped -- as noted in README, look at /runme.err on
# completion

# this is the stuff CentOS will install w/o even epel

sudo yum -y --skip-broken install ImageMagick aspell elinks emacs enscript expect firefox ftp gnuplot gpm graphviz html2ps lynx mrtg nano nmap ntpdate perl-CPAN postgresql postgresql-server rdate samba screen sendmail sendmail-cf tcsh telnet tigervnc tigervnc-server tk tmpwatch wget xinetd xorg-x11-apps xsane xterm yum-utils zlib-devel zlib-static "perl-Digest-*" "perl-Date-*" "perl-DateTime-*" "perl-File-*" perl-GD "perl-HTML-*" "perl-HTTP-*" "perl-IO-*" "perl-IPC-*" perl-Inline "perl-JSON-*" "perl-LWP-*" "perl-Net-*" "perl-Number-*" "perl-Text-*"

# now install epel and try it on packages raw centos won't install

sudo yum -y install epel-release

sudo yum -y --skip-broken install R alpine ast audacity curlftpfs erfa fuse-encfs fuse-sshfs fvwm getmail libnova nagios-plugins ncftp onionshare p7zip parallel "perl-MIME-*" "perl-Math-*" perl-OpenGL perl-utf8-all pidgin privoxy pyephem python2-astropy qgis qhull recordmydesktop stellarium tor unrtf x11vnc xcalc xdotool xemacs xemacs-packages-extra-el xpdf mariadb-server rh-java-common-lucene

# still to go: sudo yum -y install PySolFC bindfs dosbox dosemu esmtp-local-delivery esniper feh fuse-zip gnumeric libpuzzle libpuzzle-devel lucene mariadb-server perl-Flickr-* perl-Imager python3-astropy rdesktop recoll rxvt sagemath-notebook snownews stella vice xteddy xv vlc mplayer mencoder

# TODO: figure out Perl stuff I need

# this installs cpan stuff (env var minimizes prompts)

PERL_MM_USE_DEFAULT=1

# TODO: use chkconfig now
# TODO: why does mysqld NOT work even after I install mariadb? (and nagios)
# sudo systemctl enable postgresql dnsmasq httpd sendmail
# sudo systemctl start postgresql dnsmasq httpd sendmail

# bootstrap the user crontab process


