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

# TODO: I shouldnt have to do this
sudo mkdir -p /var/nagios/

# and IP/DNS fixups

# TODO: see if I still need this

# rm /etc/sysconfig/network-scripts/ifcfg-enp1s0
# ln -s /home/user/BCGIT/FEDORA/ifcfg-enp1s0 /etc/sysconfig/network-scripts/
# rm /etc/resolv.conf
# ln -s /home/user/BCGIT/FEDORA/resolv.conf /etc/

