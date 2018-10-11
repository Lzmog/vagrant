# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
#Vagrant::DEFAULT_SERVER_URL.replace('https://vagrantcloud.com')
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.vm.box = "ubuntu/trusty64"
	#config.vm.box_version = "0"
	config.vm.network "forwarded_port", guest: 80, host: 80
   	config.vm.network "forwarded_port", guest: 3306, host: 8889
	config.ssh.forward_agent = true
	config.ssh.forward_x11 = true

    # Mount shared folder using NFS
    config.vm.synced_folder "c:/www", "/var/www/html"

    config.vm.provision :shell, :path => "bootstrap.sh"
	
	config.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", "1024"]
 end

end
