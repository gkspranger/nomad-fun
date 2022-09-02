$base = <<-SCRIPT
# clean up
yum clean all

# setup hashi repo
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

# setup nomad 1
useradd -u 5000 nomad

# install packages
dnf -y install nomad git

# setup nomad 2
nomad -autocomplete-install
rm -fr /etc/nomad.d/*
rm -fr /usr/lib/systemd/system/nomad.service
mkdir -p /opt/nomad/{server,alloc,client,plugins,data}
chown nomad:nomad /opt/nomad/*
touch /var/log/nomad.log
chown nomad:nomad /var/log/nomad.log
cp /vagrant/nomad/nomad.sudoers /etc/sudoers.d/nomad
cp /vagrant/nomad/nomad.service /etc/systemd/system/nomad.service
SCRIPT

$server = <<-SCRIPT
cp /vagrant/nomad/nomad.server.hcl /etc/nomad.d/nomad.hcl
systemctl daemon-reload
systemctl start nomad.service
SCRIPT

$client_ws = <<-SCRIPT
yum -y install python39-devel
cp /vagrant/nomad/nomad.client_ws.hcl /etc/nomad.d/nomad.hcl
systemctl daemon-reload
systemctl start nomad.service
SCRIPT

$client_wh = <<-SCRIPT
yum -y install python39-devel
cp /vagrant/nomad/nomad.client_wh.hcl /etc/nomad.d/nomad.hcl
systemctl daemon-reload
systemctl start nomad.service
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.define "server1" do |n|
    n.vm.box = "bento/rockylinux-8"
    n.vm.hostname = "server1"

    n.vm.provider "parallels" do |p|
      p.memory = 2048
      p.cpus = 1
    end

    n.vm.network :private_network, ip: "192.168.10.10"
    n.vm.network "forwarded_port", guest: 4646, host: 4646

    n.vm.provision "shell", inline: $base
    n.vm.provision "shell", inline: $server
  end

  config.vm.define "client1" do |n|
    n.vm.box = "bento/rockylinux-8"
    n.vm.hostname = "client1"

    n.vm.provider "parallels" do |p|
      p.memory = 2048
      p.cpus = 1
    end

    n.vm.network :private_network, ip: "192.168.10.20"
    n.vm.network "forwarded_port", guest: 4646, host: 5646

    n.vm.provision "shell", inline: $base
    n.vm.provision "shell", inline: $client_ws
  end

  config.vm.define "client2" do |n|
    n.vm.box = "bento/rockylinux-8"
    n.vm.hostname = "client2"

    n.vm.provider "parallels" do |p|
      p.memory = 2048
      p.cpus = 1
    end

    n.vm.network :private_network, ip: "192.168.10.30"
    n.vm.network "forwarded_port", guest: 4646, host: 6646

    n.vm.provision "shell", inline: $base
  end
end
