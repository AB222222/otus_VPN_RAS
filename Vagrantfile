# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
:serverras => {
        :box_name => "centos/7",
        :net => [
                   {ip: '192.168.10.150', adapter: 2, bridge: "wlp2s0"},
                ]
  },
}

Vagrant.configure("2") do |config|

  MACHINES.each do |boxname, boxconfig|
    config.vm.synced_folder "./", "/vagrant"
    config.vm.define boxname do |box|

        box.vm.provider :virtualbox do |vb|
          vb.customize ["modifyvm", :id, "--memory", "512"]
        end

        box.vm.box = boxconfig[:box_name]

        box.vm.host_name = boxname.to_s

        boxconfig[:net].each do |ipconf|
          box.vm.network "private_network", ipconf
        end

        box.vm.network "forwarded_port", guest: 1194, host: 1194, host_ip: "127.0.0.1"

        box.vm.provision "shell", inline: <<-SHELL
          mkdir -p ~root/.ssh
                cp ~vagrant/.ssh/auth* ~root/.ssh
        SHELL

        case boxname.to_s
        when "serverras"
          config.vm.provision "shell", path: "serverras.sh"
        end

      end

  end

end
