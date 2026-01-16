#!/bin/bash
dnf update -y
dnf install -y nginx
systemctl start nginx
systemctl enable nginx
sudo rm -f /usr/share/nginx/html/index.html
systemctl restart nginx
echo "<h1>NGINX Installed Successfully....!!!</h1> 
<p>EC2 Instance is running fine :) </p>" >> /usr/share/nginx/html/index.html

