# try to get links to ALL README files (overkill?)

# need to manually handle /home/user/BCGIT/README after this
find /home/user/BCGIT -name README | perl -nle '$x=$_;s%/home/user/BCGIT/(.*?)/README%%; $dir = $1; $dir=~s%/%.%g; $dir=lc($dir); print "ln -s $x README.$dir"'
