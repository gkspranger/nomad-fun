$base = <<-SCRIPT
# clean up
yum clean all

# setup hashi repo
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

# install packages
dnf -y install consul nomad net-tools tree git wget

# setup nomad
consul -autocomplete-install
nomad -autocomplete-install

mkdir /var/log/consul
chown -R consul:consul /var/log/consul
SCRIPT

$server = <<-SCRIPT
# config nomad
wget https://github.com/hashicorp/nomad-pack/releases/download/nightly/nomad-pack-0.0.1.techpreview.4-1.x86_64.rpm
dnf -y install nomad-pack*

sudo cp /vagrant/consul/server.hcl /etc/consul.d/consul.hcl
sudo cp /vagrant/nomad/server.hcl /etc/nomad.d/nomad.hcl
SCRIPT

$lb = <<-SCRIPT
# config nomad
echo 'bind_addr = "192.168.50.20"' > /etc/consul.d/bind.hcl
sudo cp /vagrant/consul/client.hcl /etc/consul.d/consul.hcl
sudo cp /vagrant/nomad/lb.hcl /etc/nomad.d/nomad.hcl
SCRIPT

$app = <<-SCRIPT
# config nomad
echo 'bind_addr = "192.168.50.30"' > /etc/consul.d/bind.hcl
sudo cp /vagrant/consul/client.hcl /etc/consul.d/consul.hcl
sudo cp /vagrant/nomad/app.hcl /etc/nomad.d/nomad.hcl
SCRIPT

$javaapp = <<-SCRIPT
# config nomad
sudo cp /vagrant/nomad/javaapp.hcl /etc/nomad.d/nomad.hcl
SCRIPT

$start = <<-SCRIPT
# start nomad
systemctl start consul.service
sleep 10
systemctl start nomad.service
SCRIPT

$consul_kv = <<-SCRIPT
# config consul kvs
sleep 10
consul kv put apps/dev/blueapp/env1 iamenv1
consul kv put apps/dev/blueapp/env2 iamenv2
consul kv put apps/dev/blueapp/env3 iamenv3
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.define "server1" do |n|
    n.vm.box = "rockylinux/9"
    n.vm.hostname = "server1"

    n.vm.network "forwarded_port", guest: 4646, host: 4646
    n.vm.network "forwarded_port", guest: 8500, host: 8500
    n.vm.network "private_network", ip: "192.168.50.10"

    n.vm.provision "shell", inline: $base
    n.vm.provision "shell", inline: $server
    n.vm.provision "shell", inline: $start
    n.vm.provision "shell", inline: $consul_kv

    n.vm.provider "virtualbox" do |p|
      p.memory = 2048
      p.cpus = 1
    end
  end

  config.vm.define "lb1" do |n|
    n.vm.box = "rockylinux/9"
    n.vm.hostname = "lb1"

    n.vm.network "forwarded_port", guest: 4646, host: 5646
    n.vm.network "forwarded_port", guest: 8080, host: 8080
    n.vm.network "forwarded_port", guest: 9080, host: 9080
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

  config.vm.define "javaapp1" do |n|
    n.vm.box = "rockylinux/9"
    n.vm.hostname = "javaapp1"

    n.vm.network "forwarded_port", guest: 4646, host: 7646
    n.vm.network "private_network", ip: "192.168.50.40"

    n.vm.provision "shell", inline: $base
    n.vm.provision "shell", inline: $javaapp
    n.vm.provision "shell", inline: $start

    n.vm.provider "virtualbox" do |p|
      p.memory = 2048
      p.cpus = 1
    end
  end
end
