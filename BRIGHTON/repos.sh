# install the trusted repos

yum -y install epel-release
yum -y install https://forensics.cert.org/cert-forensics-tools-release-el7.rpm
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm

