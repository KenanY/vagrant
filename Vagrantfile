# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  
  # Ubuntu 14.04 x64 with Puppet 3.7.1
  config.vm.box = 'puppetlabs/ubuntu-14.04-64-puppet'

  config.vm.network 'private_network', ip: '192.168.20.20'
  config.vm.network :forwarded_port, guest: 81, host: 8181    #nginx-website
  config.vm.network :forwarded_port, guest: 82, host: 8182    #nginx-static
  config.vm.network :forwarded_port, guest: 6379, host: 6379  #redis
  config.vm.network :forwarded_port, guest: 3306, host: 8002  #mysql

  config.vm.synced_folder '../', '/vagrant'
  config.vm.provision 'shell', path: 'init.sh'
  
  # Box specs
  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2

    # NPM install requires symlinks to be created in shared folder 
    # Note: On Windows this requires 'vagrant up' to be run as Administrator OhKrappa
    v.customize ["setextradata", :id, "VBoxInternal2/SharedFoldersEnableSymlinksCreate/v-root", "1"]
  end

  # Run puppet build, using modules prepared with init.sh
  config.vm.provision "puppet" do |puppet|
    puppet.manifests_path = 'puppet/manifests'
  end

  config.vm.provision 'shell', inline: 'service nginx restart'
end
