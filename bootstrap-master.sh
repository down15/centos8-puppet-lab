#!/bin/sh

echo "Bootstrapping Puppet Master"

# Update the vagrant box
#sudo dnf update -y

# Ignore provision if puppetserver is installed
if ps aux | grep "puppetserver" | grep -v grep 2> /dev/null
then
    echo "Puppet Master is already installed. Exiting..."
else
    # Epel repo
    #sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

    # Add Puppet repo and install puppetserver
    sudo dnf install -y https://yum.puppetlabs.com/puppet-release-el-8.noarch.rpm
    sudo dnf install -y puppetserver

    # Ensure latest
    sudo /opt/puppetlabs/bin/puppet resource package puppetserver ensure=latest

    # Open port 8140 on the firewall
    sudo systemctl start firewalld.service
    sudo systemctl enable firewalld.service

    sudo firewall-cmd --add-port=8140/tcp --permanent
    sudo firewall-cmd --reload

    # Puppet module installs
    sudo /opt/puppetlabs/bin/puppet module install puppetlabs-motd

    # Soft link site.pp from vagrant folder to the puppetmaster
    ln -s /vagrant/site.pp /etc/puppetlabs/code/environments/production/manifests/site.pp

    # test.lab hosts file
    echo "" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "# test.lab hosts entries" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.69.5 puppet puppetmaster puppetmaster.test.lab"  | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.69.10 puppet-node-01 puppet-node-01.test.lab" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "192.168.69.20 puppet-node-02 puppet-node-02.test.lab" | sudo tee --append /etc/hosts 2> /dev/null 


    cat > /etc/puppetlabs/puppet/autosign.conf << EOF
*.test.lab
EOF

    # Start the puppetserver and enable via systemd
    sudo systemctl start puppetserver
    sudo systemctl enable puppetserver
    sudo systemctl status puppetserver

fi

