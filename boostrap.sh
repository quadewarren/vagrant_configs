#!/usr/bin/env bash

# Variables
APPENV=local
DBHOST=localhost
DBNAME=whiteboard
DBUSER=whiteboard_user
DBPASSWD='3PzJWhL^$ph2Xovd9Q$L2aN'

apt-get update
apt-get upgrade

echo -e "\n--- Install MySQL specific packages and settings ---\n"
echo "mysql-server mysql-server/root_password password $DBPASSWD" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $DBPASSWD" | debconf-set-selections 

apt-get -y install mysql-server-5.6 > /dev/null 2>&1
apt-get install tomcat7
apt-get install fail2ban

ufw allow 22
ufw allow 443
ufw allow 8080
ufw allow 8443
ufw allow 80
ufw allow 3306
ufw allow 8005
ufw allow 9696
ufw allow 9695
ufw allow 465
ufw enable

cp /vagrant/sshd_config  /etc/ssh/sshd_config
/etc/init.d/ssh restart

cp /vagrant/fstab /etc/fstab

useradd csuser
adduser csuser sudo

usermod -a -G admin csuser
dpkg-statoverride --update --add root admin 4750 /bin/su

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
