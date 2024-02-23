#!/bin/bash

# 提示用户按下 Enter 键以更新包列表并升级系统
read -p "Press Enter to update package list and upgrade system..."
sudo apt update
sudo apt upgrade

# 提示用户按下 Enter 键以安装 Apache
read -p "Press Enter to install Apache..."
sudo apt install apache2

# 提示用户按下 Enter 键以安装 MySQL 服务器和进行安全设置
read -p "Press Enter to install MySQL server and secure installation..."
sudo apt install mysql-server
sudo mysql_secure_installation

# 提示用户按下 Enter 键以安装 PHP 和其扩展
read -p "Press Enter to install PHP and its extensions..."
sudo apt install php libapache2-mod-php php-mysql

# 提示用户按下 Enter 键以重启 Apache
read -p "Press Enter to restart Apache..."
sudo systemctl restart apache2

# 提示用户按下 Enter 键以下载和解压缩 WordPress
read -p "Press Enter to download and extract WordPress..."
wget https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz

# 提示用户按下 Enter 键以将 WordPress 文件移动到 Apache 的 Web 目录
read -p "Press Enter to move WordPress files to Apache's web directory..."
sudo mv wordpress/* /var/www/html/

# 提示用户按下 Enter 键以设置 WordPress 目录的权限
read -p "Press Enter to set permissions for the WordPress directory..."
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/

# 询问用户要使用的 MySQL 数据库名称、用户名和密码
read -p "Enter the MySQL database name: " dbname
read -p "Enter the MySQL username: " dbuser
read -sp "Enter the MySQL password: " dbpass

# 创建 MySQL 数据库和用户
mysql -u root -p -e "CREATE DATABASE $dbname;"
mysql -u root -p -e "CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$dbpass';"
mysql -u root -p -e "GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'localhost';"
mysql -u root -p -e "FLUSH PRIVILEGES;"

# 询问用户域名
read -p "Enter your domain name (e.g., example.com): " domain

# 询问用户是否启用 HTTPS
read -p "Do you want to enable HTTPS (y/n)? " enable_https

# 提示用户按下 Enter 键以修改 Apache 配置
read -p "Press Enter to configure Apache..."
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/wordpress.conf
sudo sed -i "s/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www\/html\/wordpress/" /etc/apache2/sites-available/wordpress.conf
sudo sed -i "s/ServerName localhost/ServerName $domain/" /etc/apache2/sites-available/wordpress.conf

# 如果用户启用了 HTTPS，则安装并配置 Let's Encrypt 证书
if [ "$enable_https" == "y" ]; then
    sudo apt install certbot python3-certbot-apache
    sudo certbot --apache -d $domain
fi

sudo a2ensite wordpress
sudo a2enmod rewrite
sudo systemctl restart apache2

# 提示用户按下 Enter 键以修改 WordPress 配置文件
read -p "Press Enter to configure WordPress..."
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sed -i "s/database_name_here/$dbname/" /var/www/html/wp-config.php
sed -i "s/username_here/$dbuser/" /var/www/html/wp-config.php
sed -i "s/password_here/$dbpass/" /var/www/html/wp-config.php

# 提示用户按下 Enter 键以清理安装文件
read -p "Press Enter to clean up installation files..."
rm -rf latest.tar.gz wordpress

# 输出安装完成信息
echo "WordPress installation completed. Visit http://$domain to complete the setup."

# 提示用户按下 Enter 键以重启 Apache
read -p "Press Enter to restart Apache..."
sudo systemctl restart apache2

