{\rtf1\ansi\ansicpg936\cocoartf2759
\cocoatextscaling0\cocoaplatform0{\fonttbl\f0\fswiss\fcharset0 Helvetica;}
{\colortbl;\red255\green255\blue255;}
{\*\expandedcolortbl;;}
\paperw11900\paperh16840\margl1440\margr1440\vieww19600\viewh11900\viewkind0
\pard\tx720\tx1440\tx2160\tx2880\tx3600\tx4320\tx5040\tx5760\tx6480\tx7200\tx7920\tx8640\pardirnatural\partightenfactor0

\f0\fs36 \cf0 #!/bin/bash\
\
# \uc0\u25552 \u31034 \u29992 \u25143 \u25353 \u19979  Enter \u38190 \u20197 \u26356 \u26032 \u21253 \u21015 \u34920 \u24182 \u21319 \u32423 \u31995 \u32479 \
read -p "Press Enter to update package list and upgrade system..."\
sudo apt update\
sudo apt upgrade\
\
# \uc0\u25552 \u31034 \u29992 \u25143 \u25353 \u19979  Enter \u38190 \u20197 \u23433 \u35013  Apache\
read -p "Press Enter to install Apache..."\
sudo apt install apache2\
\
# \uc0\u25552 \u31034 \u29992 \u25143 \u25353 \u19979  Enter \u38190 \u20197 \u23433 \u35013  MySQL \u26381 \u21153 \u22120 \u21644 \u36827 \u34892 \u23433 \u20840 \u35774 \u32622 \
read -p "Press Enter to install MySQL server and secure installation..."\
sudo apt install mysql-server\
sudo mysql_secure_installation\
\
# \uc0\u25552 \u31034 \u29992 \u25143 \u25353 \u19979  Enter \u38190 \u20197 \u23433 \u35013  PHP \u21644 \u20854 \u25193 \u23637 \
read -p "Press Enter to install PHP and its extensions..."\
sudo apt install php libapache2-mod-php php-mysql\
\
# \uc0\u25552 \u31034 \u29992 \u25143 \u25353 \u19979  Enter \u38190 \u20197 \u37325 \u21551  Apache\
read -p "Press Enter to restart Apache..."\
sudo systemctl restart apache2\
\
# \uc0\u25552 \u31034 \u29992 \u25143 \u25353 \u19979  Enter \u38190 \u20197 \u19979 \u36733 \u21644 \u35299 \u21387 \u32553  WordPress\
read -p "Press Enter to download and extract WordPress..."\
wget https://wordpress.org/latest.tar.gz\
tar -xzvf latest.tar.gz\
\
# \uc0\u25552 \u31034 \u29992 \u25143 \u25353 \u19979  Enter \u38190 \u20197 \u23558  WordPress \u25991 \u20214 \u31227 \u21160 \u21040  Apache \u30340  Web \u30446 \u24405 \
read -p "Press Enter to move WordPress files to Apache's web directory..."\
sudo mv wordpress/* /var/www/html/\
\
# \uc0\u25552 \u31034 \u29992 \u25143 \u25353 \u19979  Enter \u38190 \u20197 \u35774 \u32622  WordPress \u30446 \u24405 \u30340 \u26435 \u38480 \
read -p "Press Enter to set permissions for the WordPress directory..."\
sudo chown -R www-data:www-data /var/www/html/\
sudo chmod -R 755 /var/www/html/\
\
# \uc0\u35810 \u38382 \u29992 \u25143 \u35201 \u20351 \u29992 \u30340  MySQL \u25968 \u25454 \u24211 \u21517 \u31216 \u12289 \u29992 \u25143 \u21517 \u21644 \u23494 \u30721 \
read -p "Enter the MySQL database name: " dbname\
read -p "Enter the MySQL username: " dbuser\
read -sp "Enter the MySQL password: " dbpass\
\
# \uc0\u21019 \u24314  MySQL \u25968 \u25454 \u24211 \u21644 \u29992 \u25143 \
mysql -u root -p -e "CREATE DATABASE $dbname;"\
mysql -u root -p -e "CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$dbpass';"\
mysql -u root -p -e "GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'localhost';"\
mysql -u root -p -e "FLUSH PRIVILEGES;"\
\
# \uc0\u35810 \u38382 \u29992 \u25143 \u22495 \u21517 \
read -p "Enter your domain name (e.g., example.com): " domain\
\
# \uc0\u35810 \u38382 \u29992 \u25143 \u26159 \u21542 \u21551 \u29992  HTTPS\
read -p "Do you want to enable HTTPS (y/n)? " enable_https\
\
# \uc0\u25552 \u31034 \u29992 \u25143 \u25353 \u19979  Enter \u38190 \u20197 \u20462 \u25913  Apache \u37197 \u32622 \
read -p "Press Enter to configure Apache..."\
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/wordpress.conf\
sudo sed -i "s/DocumentRoot \\/var\\/www\\/html/DocumentRoot \\/var\\/www\\/html\\/wordpress/" /etc/apache2/sites-available/wordpress.conf\
sudo sed -i "s/ServerName localhost/ServerName $domain/" /etc/apache2/sites-available/wordpress.conf\
\
# \uc0\u22914 \u26524 \u29992 \u25143 \u21551 \u29992 \u20102  HTTPS\u65292 \u21017 \u23433 \u35013 \u24182 \u37197 \u32622  Let's Encrypt \u35777 \u20070 \
if [ "$enable_https" == "y" ]; then\
    sudo apt install certbot python3-certbot-apache\
    sudo certbot --apache -d $domain\
fi\
\
sudo a2ensite wordpress\
sudo a2enmod rewrite\
sudo systemctl restart apache2\
\
# \uc0\u25552 \u31034 \u29992 \u25143 \u25353 \u19979  Enter \u38190 \u20197 \u20462 \u25913  WordPress \u37197 \u32622 \u25991 \u20214 \
read -p "Press Enter to configure WordPress..."\
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php\
sed -i "s/database_name_here/$dbname/" /var/www/html/wp-config.php\
sed -i "s/username_here/$dbuser/" /var/www/html/wp-config.php\
sed -i "s/password_here/$dbpass/" /var/www/html/wp-config.php\
\
# \uc0\u25552 \u31034 \u29992 \u25143 \u25353 \u19979  Enter \u38190 \u20197 \u28165 \u29702 \u23433 \u35013 \u25991 \u20214 \
read -p "Press Enter to clean up installation files..."\
rm -rf latest.tar.gz wordpress\
\
# \uc0\u36755 \u20986 \u23433 \u35013 \u23436 \u25104 \u20449 \u24687 \
echo "WordPress installation completed. Visit http://$domain to complete the setup."\
\
# \uc0\u25552 \u31034 \u29992 \u25143 \u25353 \u19979  Enter \u38190 \u20197 \u37325 \u21551  Apache\
read -p "Press Enter to restart Apache..."\
sudo systemctl restart apache2\
\
}