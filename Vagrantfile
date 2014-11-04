# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|

  config.vm.box = 'precise64'
  config.vm.box_url = 'http://files.vagrantup.com/precise64.box'

  config.vm.network 'private_network', ip: '192.168.20.20'
  config.vm.network :forwarded_port, guest: 81, host: 8181    #nginx-website
  config.vm.network :forwarded_port, guest: 82, host: 8182    #nginx-static
  config.vm.network :forwarded_port, guest: 6379, host: 6379  #redis
  config.vm.network :forwarded_port, guest: 3306, host: 8002  #mysql

  config.vm.synced_folder '../', '/vagrant'
  config.vm.provision 'shell', path: 'init.sh'

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = 'puppet/manifests'
    puppet.module_path    = 'puppet/modules'
    puppet.options        = '--verbose --debug'
  end

  config.vm.provision 'shell', inline: 'service nginx restart'

end
