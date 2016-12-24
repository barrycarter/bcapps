# useful symlinks

# TODO: can I add a "if you are not root, then die" check here?

# TODO: for all symlinks, worry if symlink already exists?

# TODO: maybe write program that checks symlink, ignores if exists
# with right value, complains is file exists and is not a symlink or
# wrong symlink

# let's me be "user" but still "be" barrycarter at the same time

ln -s /home/user /home/barrycarter

# lets me reference my old FC11 installation copy as /old
ln -s /mnt/kemptown/dullon-root /old

# if you're using an older .fvwm2rc, this may help -- if not, it
# doesn't hurt (also for some of my programs that use direct paths)

mkdir -p /usr/lib/X11 /usr/X11R6/
ln -s /usr/libexec/fvwm/2.6.6 /usr/lib/X11/fvwm2
ln -s /bin /usr/X11R6/

# networking (must copy, /home/user/BCGIT doesnt exist early enough)

rm /etc/sysconfig/network-scripts/ifcfg-enp0s3
cp /home/user/BCGIT/BRIGHTON/ifcfg-enp0s3 /etc/sysconfig/network-scripts/

# startup (/etc/rc.local is just a symlink)
rm /etc/rc.d/rc.local

# this MUST be a copy, not a symlink since /home/user/BCGIT doesnt
# exist early enough

cp /home/user/BCGIT/BRIGHTON/rc.local /etc/rc.d

# other helpful symlinks if you're using older software or programs
# that rely on a specific path (or my bclib.pl):

ln -s /bin/php /usr/local/bin/
ln -s /bin/urxvt /bin/rxvt
ln -s /home/user/BCGIT/bclib.pl /usr/local/lib/

# symlinks of important files to BCGIT

: startup-x.csh and startup-nox.csh no longer exist but I want to
: remove them just in case they snuck in from other sources

: .login is probably irrelevant but just to play it safe

rm -f /home/user/.xinitrc /home/user/brighton-procs.txt /home/user/startup-x.sh /home/user/startup-nox.sh /home/user/.tcshrc /home/user/.Xresources /home/user/.fvwm/.fvwm2rc /home/user/.login

ln -s /home/user/BCGIT/BRIGHTON/.tcshrc /home/user/BCGIT/BRIGHTON/.xinitrc /home/user/BCGIT/BRIGHTON/brighton-procs.txt /home/user/BCGIT/BRIGHTON/.Xresources /home/user

: root should use dot files from user

rm -f /root/.xinitrc /root/.tcshrc /root/.Xresources /root/.fvwm/.fvwm2rc /root/.login

ln -s /home/user/.xinitrc /home/user/.tcshrc /home/user/.Xresources /root

: fvwm2 now keeps configs here
ln -s /home/user/BCGIT/BRIGHTON/.fvwm2rc /home/user/.fvwm/

ln -s /home/user/.fvwm/.fvwm2rc /root/.fvwm

# and some because I'm using older system

ln -s /usr/share/dict /usr/

# TODO: maybe make this a cp if it occurs too early
rm /etc/hosts
ln -s /home/user/BCGIT/BRIGHTON/hosts /etc

# directories my programs use and chown them to user
# TODO: try to generalize more for /var/tmp but note it has "/tmp" perms
# NOTE: I want to keep my nagios stuff where it was before thus /var/nagios
# /var/log/nagios/rw should NOT be necessary bug workaround
mkdir -p /usr/local/etc/locks /usr/local/etc/registry /var/tmp/montastic /var/tmp/cache /var/nagios/rw /var/log/nagios/rw
chown -R user /usr/local/etc /var/tmp/*
chown -R nagios /var/nagios /var/log/nagios

# TODO: I shouldnt have to do this
mkdir -p /var/nagios/

# pwless sudo access for wheel and no tty requirement

rm -f /etc/sudoers.d/wheel /etc/sudoers.d/tty
echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel

# this works fine from a shell script (ie, the exclamation mark isn't
# expanded) POSSIBLY because "set noglob" is set magically somehow

echo 'Defaults !requiretty' > /etc/sudoers.d/tty

# this creates mount points if I want to mount dullon's external
# drives as though they were local (some of these no longer exist, but
# it doesnt hurt to create mount points)

mkdir -p /mnt/extdrive2 /mnt/extdrive3 /mnt/extdrive4 /mnt/extdrive5

# I moved contents of /mnt/extdrive to /mnt/extdrive5/extdrive, this
# symlink allows me to access it with the old name

ln -s /mnt/extdrive5/extdrive /mnt
