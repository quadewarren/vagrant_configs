#!/bin/bash
DBPASSWD='3PzJWhL^$ph2Xovd9Q$L2aN'
mysql -uroot -p$DBPASSWD whiteboard < drop.sql
mysql -uroot -p$DBPASSWD whiteboard < whiteboard.sql
