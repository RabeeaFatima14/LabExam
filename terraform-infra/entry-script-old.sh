#!/bin/bash

# Update system
dnf update -y

# Install Nginx
dnf install -y nginx

# Create self-signed certificate
mkdir -p /etc/nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/nginx.key \
  -out /etc/nginx/ssl/nginx.crt \
  -subj "/C=PK/ST=Islamabad/L=Islamabad/O=MyOrg/CN=localhost"

# Create custom HTML page
cat > /usr/share/nginx/html/index.html << 'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>Rabeea's Terraform Environment</title>
</head>
<body>
    <h1>Welcome to Rabeea's Terraform Environment</h1>
    <p>This infrastructure was deployed using Terraform.</p>
    <p>Server is running Nginx with HTTPS enabled.</p>
</body>
</html>
HTML

# Configure Nginx for HTTPS
cat > /etc/nginx/conf.d/https.conf << 'NGINXCONF'
server {
    listen 443 ssl;
    server_name _;

    ssl_certificate /etc/nginx/ssl/nginx.crt;
    ssl_certificate_key /etc/nginx/ssl/nginx.key;

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
}

server {
    listen 80;
    server_name _;

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
}
NGINXCONF

# Enable and start Nginx
systemctl enable nginx
systemctl start nginx
