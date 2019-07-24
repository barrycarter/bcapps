# install the trusted repos

yum -y install epel-release
yum -y install https://forensics.cert.org/cert-forensics-tools-release-el7.rpm
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm
rpm -Uvh http://li.nux.ro/download/nux/dextop/el7/x86_64/nux-dextop-release-0-5.el7.nux.noarch.rpm

# by 7/24/19, I've added the following repos w/o explicitly mentioning
# them above

# repo id repo name status
# adobe-linux-x86_64 Adobe Systems Incorporated 3
# base/7/x86_64 CentOS-7 - Base 10019
# docker-ce-stable/x86_64 Docker CE Stable - x86_64 50
# elrepo ELRepo.org Community Enterprise Linux Repositor 114
# epel/x86_64 Extra Packages for Enterprise Linux 7 - x86_64 13323
# extras/7/x86_64 CentOS-7 - Extras 419
# forensics/7/x86_64 CERT Forensics Tools Repository 503
# forensics-splunk/7/x86_64 CERT Forensics Tools Repository - Splunk 4
# google-chrome google-chrome 3
# google-talkplugin google-talkplugin 1
# mongodb-org-4.0/7 MongoDB Repository 55
# mono-centos7-vs mono-centos7-vs 417
# nux-dextop/x86_64 Nux.Ro RPMs for general desktop use 2702
# skype-stable skype (stable) 5
# teamviewer/x86_64 TeamViewer - x86_64 19
# updates/7/x86_64 CentOS-7 - Updates 2236
# virtualbox/7/x86_64 Oracle Linux / RHEL / CentOS-7 / x86_64 - Virtu 70
# repolist: 29943
