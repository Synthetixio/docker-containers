#!/bin/sh
wget -nv https://raw.githubusercontent.com/mitchellkrogza/nginx-ultimate-bad-bot-blocker/master/conf.d/globalblacklist.conf -O /etc/nginx/conf.d/globalblacklist.conf
sed -i 's/^\t*138.199.57.151\t*1;$/#\t138.199.57.151\t\t1;/g' /etc/nginx/conf.d/globalblacklist.conf
sed -i 's/^\t*143.244.38.129\t*1;$/#\t143.244.38.129\t\t1;/g' /etc/nginx/conf.d/globalblacklist.conf
sed -i 's/^\t*195.181.163.194\t*1;$/#\t195.181.163.194\t\t1;/g' /etc/nginx/conf.d/globalblacklist.conf
sed -i 's/^\t*5.188.120.15\t*1;$/#\t5.188.120.15\t\t1;/g' /etc/nginx/conf.d/globalblacklist.conf
sed -i 's/^\t*89.187.173.66\t*1;$/#\t89.187.173.66\t\t1;/g' /etc/nginx/conf.d/globalblacklist.conf
nginx -t
service nginx reload
