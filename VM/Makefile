all: pkglist-for-egrep.txt pkglist-for-fgrep.txt filelist-for-fgrep.txt filelist-for-egrep.txt
# all: pkglist-for-egrep.txt pkglist-for-fgrep.txt filelist-for-fgrep.txt filelist-for-fgrep.txt
pkglist-for-egrep.txt: pkglist.txt
	egrep -v '^#|^$$' pkglist.txt | sort -u | perl -nle 'print "bin/$$_\$$"' > pkglist-for-egrep.txt
pkglist-for-fgrep.txt: pkglist.txt
	egrep -v '^#|^$$' pkglist.txt | sort -u > pkglist-for-fgrep.txt
filelist-for-fgrep.txt: pkglist.txt
	egrep -v '^#|^$$' pkglist.txt | sort -u | perl -nle 'print "/$$_"' > filelist-for-fgrep.txt
filelist-for-egrep.txt: pkglist.txt
	egrep -v '^#|^$$' pkglist.txt | sort -u | perl -nle 'print "/$$_\$$"' > filelist-for-egrep.txt
