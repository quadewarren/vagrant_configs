#!/usr/bin/env bash

# Variables
APPENV=local
DBHOST=localhost
DBNAME=whiteboard
DBUSER=whiteboard_user
DBPASSWD='3PzJWhL^$ph2Xovd9Q$L2aN'

sleep 30

apt-get update
apt-get -y upgrade

echo -e "\n--- Install MySQL specific packages and settings ---\n"
echo "mysql-server mysql-server/root_password password $DBPASSWD" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $DBPASSWD" | debconf-set-selections 

apt-get -y install mysql-server-5.6 > /dev/null 2>&1
apt-get -y install tomcat7
cp /vagrant/server.xml /etc/tomcat7/server.xml
cp /vagrant/tomcat-users.xml /etc/tomcat7/tomcat-users.xml
cp /vagrant/setenv.sh /usr/share/tomcat7/bin/setenv.sh
cp /vagrant/catalina-jmx-remote.jar /usr/share/tomcat7/lib/
chmod +x /usr/share/tomcat7/bin/setenv.sh
service tomcat7 restart
apt-get -y install fail2ban

cp /vagrant/sshd_config  /etc/ssh/sshd_config
/etc/init.d/ssh restart

cp /vagrant/fstab /etc/fstab

cp /vagrant/sysctl.conf /etc/sysctl.conf
cp /vagrant/jail.conf /etc/fail2ban/jail.conf

/etc/init.d/fail2ban restart

mysql -uroot -p$DBPASSWD -e "CREATE DATABASE $DBNAME"
mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'localhost' identified by '$DBPASSWD'"
mysql -uroot -p$DBPASSWD -e "grant all privileges on $DBNAME.* to '$DBUSER'@'%' identified by '$DBPASSWD'"

apt-get clean

dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

cat /dev/null > ~/.bash_history && history -c

mkdir /home/vagrant/deploy/
