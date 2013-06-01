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
yum install httpd php mysql-server php-mysql mod_ssl

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

##IP Tables##
#Reset all rules (F) and chains (X), necessary if have already defined iptables rules
iptables -t filter -F 
iptables -t filter -X 
 
#Start by blocking all traffic, this will allow secured, fine grained filtering
iptables -t filter -P INPUT DROP 
iptables -t filter -P FORWARD DROP 
iptables -t filter -P OUTPUT DROP 
 
#Keep established connexions
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 
iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT 
 
#Allow loopback
iptables -t filter -A INPUT -i lo -j ACCEPT 
iptables -t filter -A OUTPUT -o lo -j ACCEPT 
#HTTP
iptables -t filter -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 80 -j ACCEPT
#FTP 
iptables -t filter -A OUTPUT -p tcp --dport 20:21 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 20:21 -j ACCEPT
#SMTP 
iptables -t filter -A INPUT -p tcp --dport 25 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 25 -j ACCEPT
#POP3
iptables -t filter -A INPUT -p tcp --dport 110 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 110 -j ACCEPT
#IMAP
iptables -t filter -A INPUT -p tcp --dport 143 -j ACCEPT 
iptables -t filter -A OUTPUT -p tcp --dport 143 -j ACCEPT 
#ICMP
iptables -t filter -A INPUT -p icmp -j ACCEPT 
iptables -t filter -A OUTPUT -p icmp -j ACCEPT
#SSH
iptables -t filter -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 22 -j ACCEPT
#DNS
iptables -t filter -A OUTPUT -p tcp --dport 53 -j ACCEPT
iptables -t filter -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 53 -j ACCEPT
iptables -t filter -A INPUT -p udp --dport 53 -j ACCEPT
#NTP
iptables -t filter -A OUTPUT -p udp --dport 123 -j ACCEPT

##Webmin##

echo "[Webmin]
name=Webmin Distribution Neutral
#baseurl=http://download.webmin.com/download/yum
mirrorlist=http://download.webmin.com/download/yum/mirrorlist
enabled=1" > /etc/yum.repos.d/webmin.repo

wget -P /tmp http://www.webmin.com/jcameron-key.asc
rpm --import /tmp/jcameron-key.asc

yum -y install webmin