 #!/bin/bash
yum update -y
yum install -y httpd awscli
systemctl start httpd
systemctl enable httpd
aws s3 cp s3://rosestore.fun/index.html /var/www/html/index.html --region us-east-1