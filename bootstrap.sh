#!/usr/bin/env bash

Update () {
    echo "-- Update packages --"
    sudo apt-get update
    sudo apt-get upgrade
}
Update

echo "-- Just to quiet down some error messages --"
IPADDR=$(/sbin/ifconfig eth0 | awk '/inet / { print $2 }' | sed 's/addr://')
sed -i "s/^${IPADDR}.*//" /etc/hosts
echo $IPADDR ubuntu.localhost >> /etc/hosts

echo "-- Install tools and helpers --"
sudo apt-get install -y --force-yes vim htop curl git npm python-software-properties

echo "-- Install PPA's --"
sudo add-apt-repository ppa:ondrej/php
Update

echo "-- Install NodeJS --"
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -

echo "-- Install packages --"
sudo apt-get install -y --force-yes apache2 git-core nodejs
sudo apt-get install -y --force-yes php7.1-common php7.1-dev php7.1-json php7.1-opcache php7.1-cli libapache2-mod-php7.1 php7.1 php7.1-mysql php7.1-fpm php7.1-curl php7.1-gd php7.1-mcrypt php7.1-mbstring php7.1-bcmath php7.1-zip
Update

echo "-- Install MySQL & prepare configuration for MySQL --"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password root"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password root"
sudo apt-get install -y --force-yes mysql-client mysql-server

echo "-- Setup Mysql --"
sed -i "s/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION" | mysql -u root --password=root
echo "GRANT PROXY ON ''@'' TO 'root'@'%' WITH GRANT OPTION" | mysql -u root --password=root

echo "-- Configure PHP & Apache --"
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/apache2/php.ini

echo "-- Cannot allocate  memory error fix --"
sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
sudo /sbin/mkswap /var/swap.1
sudo /sbin/swapon /var/swap.1
sudo a2enmod rewrite

echo "-- Install OCI8 --"
sudo mkdir /opt/oracle/instantclient

export LD_LIBRARY_PATH=/opt/oracle/instantclient 
export ORACLE_HOME=/opt/oracle/instantclient 

echo "Instantclient path: instantclient,/opt/oracle/instantclient"
 
sudo pecl channel-update pecl.php.net
#sudo pecl install oci8
cd /opt/oracle/instantclient

sudo ln -s libclntsh.so.11.1 libclntsh.so
sudo ln -s libocci.so.11.1 libocci.so

sudo sh -c "echo 'instantclient,/opt/oracle/instantclient' | pecl install oci8"

sudo chown -R vagrant /etc/php/7.1/apache2/php.ini

sudo echo "extension=oci8.so" >> /etc/php/7.1/fpm/php.ini
sudo echo "extension=oci8.so" >> /etc/php/7.1/cli/php.ini
sudo echo "extension=oci8.so" >> /etc/php/7.1/apache2/php.ini

sudo chown -R root /etc/php/7.1/apache2/php.ini

sudo /etc/init.d/apache2 restart

echo "OCI pdo driver"
cd /opt
sudo mkdir src
cd src
sudo wget http://be.php.net/distributions/php-7.1.7.tar.gz
sudo tar xfvz php-7.1.7.tar.gz

cd php-7.1.7
cd ext
cd pdo_oci
phpize
./configure --with-pdo-oci=instantclient,/opt/oracle/instantclient
sudo make
sudo make install
sudo echo extension=pdo_oci.so > /etc/php/7.1/mods-available/pdo_oci.ini
php -i |grep oci 

#sudo touch /etc/php/7.1/mods-available/pdo_oci.ini
#sudo touch /etc/php/7.1/mods-available/oci8.ini
#sudo echo 'extension=pdo_oci.so' > /etc/php/7.1/mods-available/oci8.ini
#sudo ln -s /etc/php/7.1/mods-available/pdo_oci.ini /etc/php/7.1/apache2/conf.d/10-pdo_oci.ini
#sudo ln -s /etc/php/7.1/mods-available/oci8.ini /etc/php/7.1/apache2/conf.d/10-oci8.ini

sudo /etc/init.d/apache2 restart

echo "-- Creating virtual hosts --"
sudo ln -fs /vagrant/public/ /var/www/html
cat << EOF | sudo tee -a /etc/apache2/sites-available/default.conf
<VirtualHost *:80>
  ServerName localhost
  DocumentRoot "/var/www/html"
  <Directory "/var/www/html">
    AllowOverride all
  </Directory>
</VirtualHost>

<VirtualHost *:80>
  ServerName priemimas.local
  DocumentRoot "/var/www/html/priemimas.vgtu.lt/public"
  <Directory "/var/www/html/priemimas.vgtu.lt/public">
    AllowOverride all
  </Directory>
</VirtualHost>
EOF
sudo a2ensite default.conf

echo "-- Restart Mysql --"
sudo /etc/init.d/mysql restart

echo "-- Install Composer --"
curl -s https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer
