# -*- mode: ruby -*-
# vi: set ft=ruby :

nodes_config = (JSON.parse(File.read("puppetnodes.json")))['nodes']

API_VERSION = "2"

Vagrant.configure(API_VERSION) do |config|
    config.vm.box = "jhitz/centos8"

    nodes_config.each do |node|

        node_name    = node[0]
        node_values  = node[1]

        config.vm.define node_name do |config|
            ports = node_values['ports']
            ports.each do |port|
                config.vm.network :forwarded_port,
                    host:  port[':host'],
                    guest: port[':guest'],
                    id:    port[':id']
            end

            config.vm.hostname = node_name
            config.vm.network :private_network, ip: node_values[':ip']

            config.vm.provider :virtualbox do |vb|
                vb.customize ["modifyvm", :id, "--memory", node_values[':memory']]
                vb.customize ["modifyvm", :id, "--cpus", node_values[':cpus']]
                vb.customize ["modifyvm", :id, "--name", node_name]
            end

            config.vm.provision :shell, :path => node_values[':bootstrap']
        end
    end
end

