# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "centos64"
  config.vm.box_url = "http://packages.kopla.jyu.fi/vagrant-boxes/centos-6.4-x86-64.box"

  # SSH
  config.vm.network :forwarded_port, guest: 22, host: 2200

  # Plone
  config.vm.network :forwarded_port, guest: 8080, host: 8080
  config.vm.network :forwarded_port, guest: 8081, host: 8081
  config.vm.network :forwarded_port, guest: 8082, host: 8082

  # Rabbit MQ
  config.vm.network :forwarded_port, guest: 5672, host: 5672
  config.vm.network :forwarded_port, guest: 15672, host: 15672
  config.vm.network :forwarded_port, guest: 15674, host: 15674

  config.vm.provision :puppet do |puppet|
    puppet.module_path    = "."
    puppet.manifests_path = "."
    puppet.manifest_file  = "bootstrap.pp"
  end

  config.vm.provision :puppet do |puppet|
    puppet.module_path    = "."
    puppet.manifests_path = "."
    puppet.manifest_file  = "vagrant.pp"
    puppet.facter = {
      "rhodecode_username" => "tojuhaka",
    }
  end

  # TODO: Set your RhodeCode password for keyring
  # $ vagrant ssh
  # $ keyring set Mercurial datakurre@@https://jyuplone.cc.jyu.fi/code

  config.vm.provider "virtualbox" do |v|
    v.customize ["modifyvm", :id, "--memory", "1024"]
  end

  config.vm.provider "vmware_fusion" do |v|
    v.vmx["memsize"] = "1024"
    v.vmx["numvcpus"] = "2"
  end
end
