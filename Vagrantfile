$base = <<-SCRIPT
# clean up
yum clean all

# setup hashi repo
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

# install packages
dnf -y install nomad net-tools tree git

# setup nomad
nomad -autocomplete-install
SCRIPT

$server = <<-SCRIPT
# config nomad
sudo cp /vagrant/nomad/server.hcl /etc/nomad.d/nomad.hcl
SCRIPT

$lb = <<-SCRIPT
# config nomad
sudo cp /vagrant/nomad/lb.hcl /etc/nomad.d/nomad.hcl
SCRIPT

$app = <<-SCRIPT
# config nomad
sudo cp /vagrant/nomad/app.hcl /etc/nomad.d/nomad.hcl
SCRIPT

$start = <<-SCRIPT
# start nomad
systemctl start nomad.service
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.define "server1" do |n|
    n.vm.box = "rockylinux/9"
    n.vm.hostname = "server1"

    n.vm.network "forwarded_port", guest: 4646, host: 4646
    n.vm.network "private_network", ip: "192.168.50.10"

    n.vm.provision "shell", inline: $base
    n.vm.provision "shell", inline: $server
    n.vm.provision "shell", inline: $start

    n.vm.provider "virtualbox" do |p|
      p.memory = 2048
      p.cpus = 1
    end
  end

  config.vm.define "lb1" do |n|
    n.vm.box = "rockylinux/9"
    n.vm.hostname = "lb1"

    n.vm.network "forwarded_port", guest: 4646, host: 5646
    n.vm.network "private_network", ip: "192.168.50.20"

    n.vm.provision "shell", inline: $base
    n.vm.provision "shell", inline: $lb
    n.vm.provision "shell", inline: $start

    n.vm.provider "virtualbox" do |p|
      p.memory = 2048
      p.cpus = 1
    end
  end

  config.vm.define "app1" do |n|
    n.vm.box = "rockylinux/9"
    n.vm.hostname = "app1"

    n.vm.network "forwarded_port", guest: 4646, host: 6646
    n.vm.network "private_network", ip: "192.168.50.30"

    n.vm.provision "shell", inline: $base
    n.vm.provision "shell", inline: $app
    n.vm.provision "shell", inline: $start

    n.vm.provider "virtualbox" do |p|
      p.memory = 2048
      p.cpus = 1
    end
  end
end
