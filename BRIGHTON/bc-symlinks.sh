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

# other helpful symlinks if you're using older software or programs
# that rely on a specific path (or my bclib.pl):

ln -s /bin/php /usr/local/bin/
ln -s /bin/urxvt /bin/rxvt
ln -s /home/barrycarter/BCGIT/bclib.pl /usr/local/lib/

# symlinks of important files to BCGIT

: startup-x.csh and startup-nox.csh no longer exist but I want to
: remove them just in case they snuck in from other sources

rm -f /home/user/.xinitrc /home/user/brighton-procs.txt /home/user/startup-x.sh /home/user/startup-nox.sh /home/user/.tcshrc /home/user/.Xresources /home/user/.fvwm/.fvwm2rc

ln -s /home/user/BCGIT/BRIGHTON/.tcshrc /home/user/BCGIT/BRIGHTON/.xinitrc /home/user/BCGIT/BRIGHTON/brighton-procs.txt /home/user/BCGIT/BRIGHTON/.Xresources /home/user

: fvwm2 now keeps configs here
ln -s /home/user/BCGIT/BRIGHTON/.fvwm2rc /home/user/.fvwm/

# and some because I'm using older system

ln -s /usr/share/dict /usr/

# directories my programs use and chown them to user

mkdir -p /usr/local/etc/locks /usr/local/etc/registry /var/tmp/montastic
chown -R user /usr/local/etc /var/tmp/

# TODO: I shouldnt have to do this
mkdir -p /var/nagios/

# pwless sudo access for wheel and no tty requirement

rm -f /etc/sudoers.d/wheel /etc/sudoers.d/tty
echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel

# TODO: slightly worry that, even with quotes, "!" may not be escaped
# (works fine from command line, but...)

echo "Defaults \!requiretty" > /etc/sudoers.d/tty
