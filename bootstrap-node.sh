#!/bin/sh

echo "Bootstrapping Puppet Node"


if ps aux | grep "puppet" | grep -v grep 2> /dev/null
then
 echo "Puppet Master is already installed. Exiting..."
else
    # Update the vagrant box
    #sudo dnf update -y

    # Epel repo
    #sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

    # Add Puppet repo and install puppetserver
    sudo dnf install -y https://yum.puppetlabs.com/puppet-release-el-8.noarch.rpm

    # Install Puppet agent
    sudo dnf -y install puppet-agent

    #test.lab hosts file
    echo "" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "# test.lab hosts entries" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.69.5 puppet puppetmaster puppetmaster.test.lab"  | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.69.10 puppet-node-01 puppet-node-01.test.lab" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.69.20 puppet-node-02 puppet-node-02.test.lab" | sudo tee --append /etc/hosts 2> /dev/null 

    cat > /etc/puppetlabs/puppet/puppet.conf << EOF
[main]
server = puppetmaster.test.lab
environment = production
EOF

    # Ensure puppet agent is running
    sudo /opt/puppetlabs/bin/puppet resource service puppet ensure=running enable=true

fi