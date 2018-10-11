# Vagrant script - instant web server on your computer
This method works only on Windows OS.

Script witch will help you to download and install all the necessary libraries. (Web development)

1. Install Vagrant (be sure that Vagrant is compatible with Virtualbox)
2. Create repository, default is "www" (C:/www)
3. Open command line / powershell in www folder
2. Create Vagrant file in www folder via command line / powershell ("Vagrant init")
3. Open Vagrant file
3. Change Vagrant file content into my code and save it
4. Drop .sh file into same repository (where you created Vagrant file)
5. Open command line / powershell
6. Reach Vagrant file repository via command line / powershell , and execute Vagrant file ("Vagrant up")

It should download you ubuntu box with all necessary libraries for web development.
Basically you can add more libraries. Add your most needed libraries in bootstrap.sh (line 27)

These libraries by default would be installed:
php7.1-common php7.1-dev php7.1-json php7.1-opcache php7.1-cli
libapache2-mod-php7.1 php7.1 php7.1-mysql php7.1-fpm php7.1-curl 
php7.1-gd php7.1-mcrypt php7.1-mbstring php7.1-bcmath php7.1-zip
mysql-client mysql-server apache2 git-core nodejs

P.S. if you have old vagrant you should add this before vagrant.configure:
"Vagrant::DEFAULT_SERVER_URL.replace('https://vagrantcloud.com')"

If you want full GUI use this: 

config.vm.box = "igorbrites/ubuntu-trusty64-gui"
config.vm.box_version = "0" 

other wise use this one:

config.vm.box = "ubuntu/trusty64"

(Only on Windows) Resizing .vdi / .vdkm box:
  1. ./VBoxManage clonehd "C:\Users\52829\.VirtualBox\www_64GUI_default_1539192605655_60052\box-disk1.vmdk" "C:\Users\52829\.VirtualBox\www_64GUI_default_1539192605655_60052\clone-disk1.vdi" --format vdi
  2. ./VBoxManage modifyhd "clone-disk1.vdi" --resize size_of_mb
  3. ./VBoxManage storageattach www_64GUI_default_1539192605655_60052 --storagectl "SATA" --port 0 --device 0 --type hdd --medium "C:\Users\52829\.VirtualBox\www_64GUI_default_1539192605655_60052\clone-disk1.vdi"




I hope i helped you! :)
