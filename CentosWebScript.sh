############# CentOS 6 Web Script ###########

#This script is meant as an add on to the Hardening Script,
#it installs the basic software and security conscious
#rules to get a LAMP based webserver up and running.

#Look for "*Change This*" throughout the script to specific
#system settings that must be altered.

#Please review the sources below to understand what this
#script is actually doing.

###Sources###
#Created from:
#http://wiki.centos.org/HowTos/OS_Protection
#http://benchmarks.cisecurity.org/downloads/show-single/?file=rhel6.100
#http://www.nsa.gov/ia/_files/os/redhat/rhel5-guide-i731.pdf

#####Webserver#####

#Install/Start Webserver Components
#Depending on site/cms you may need to add functionality (i.e. php-xml php-gd php-mbstring)
#*Change This* 
yum -y install httpd php mysql-server php-mysql mod_ssl openssl php-mcrypt 
service httpd start
service mysqld start

chkconfig httpd on
chkconfig mysqld on

##Apache##

mkdir -p /etc/httpd/vhosts.d
echo "Include vhosts.d/*.conf" >> /etc/httpd/conf/httpd.conf

#*Change This* Change the domains to your own or add multiple
mkdir -p /var/srv/vhosts/example.com/htdocs
chown apache:apache /var/srv/vhosts/example.com/htdocs -R

##FIREWALL##
#Vars *Change This*
 NET=venet0
 HOST=0.0.0.0

#Create a HTTPD chain

 iptables -N HTTPD
 
#Filter the INPUT chain
 iptables -t filter -I INPUT 23 -j HTTPD
 
#HTTPD Chain
 iptables -A HTTPD -m state --state NEW -i $NET -p tcp -s 0/0 -d $HOST --dport http --syn -j ACCEPT
 iptables -A HTTPD -m state --state NEW -i $NET -p tcp -s 0/0 -d $HOST --dport https --syn -j ACCEPT
 iptables -A HTTPD -j RETURN
 
#Add Rule for Webmin port
#*Change This* after you setup webmin
iptables -I INPUT 4 -p tcp --dport 10000 -j ACCEPT
 
#Save settings

 /sbin/service iptables save

#List rules

 iptables -L -v

##Webmin##

echo "[Webmin]
name=Webmin Distribution Neutral
#baseurl=http://download.webmin.com/download/yum
mirrorlist=http://download.webmin.com/download/yum/mirrorlist
enabled=1" > /etc/yum.repos.d/webmin.repo

wget -P /tmp http://www.webmin.com/jcameron-key.asc
rpm --import /tmp/jcameron-key.asc

yum -y install webmin

#Setup the rest via webmin