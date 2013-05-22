############# CentOS 6 Web Script ###########

#This script is meant to take basic steps in hardening your
#Centos6.X environment remember however that no system is
#foolproof and watching your logs is the best defense
#against intruders and malicious activity.

#Look for "*Change This*" throughout the script to specific
#system settings that must be altered.

#Also make sure that if you are using ssh to log into your
#your server to add another user, other than root, and add them
#to the ssh group

#Please review the sources below to understand what this
#script is actually doing.

###Sources###
#Created from:
#http://wiki.centos.org/HowTos/OS_Protection
#http://benchmarks.cisecurity.org/downloads/show-single/?file=rhel6.100
#http://www.nsa.gov/ia/_files/os/redhat/rhel5-guide-i731.pdf

#####Webserver#####
yum install httpd php mysql-server php-mysql

service httpd start
service mysqld start

chkconfig httpd on
chkconfig mysqld on

##Apache##

mkdir -p /etc/httpd/vhosts.d
echo "Include vhosts.d/*.conf" >> /etc/httpd/conf/httpd.conf

#*Change This*
mkdir -p /var/www/vhosts/example.com/htdocs
chown apache:apache /var/www -R


##Webmin##

echo "[Webmin]
name=Webmin Distribution Neutral
#baseurl=http://download.webmin.com/download/yum
mirrorlist=http://download.webmin.com/download/yum/mirrorlist
enabled=1" > /etc/yum.repos.d/webmin.repo

wget -P /tmp http://www.webmin.com/jcameron-key.asc
rpm --import /tmp/jcameron-key.asc

yum -y install webmin