$setup = <<-SCRIPT
systemctl daemon-reload
systemctl start nomad.service
SCRIPT

Vagrant.configure("2") do |config|
  config.vm.define "server1" do |n|
    n.vm.box = "nomad-server-base"
    n.vm.hostname = "server1"

    n.vm.provider "parallels" do |p|
      p.memory = 2048
      p.cpus = 1
    end

    n.vm.network :private_network, ip: "192.168.10.10"
    n.vm.network "forwarded_port", guest: 4646, host: 4646

    n.vm.provision "shell", inline: $setup
  end

  config.vm.define "ws-client1" do |n|
    n.vm.box = "ws-base"
    n.vm.hostname = "ws-client1"

    n.vm.provider "parallels" do |p|
      p.memory = 2048
      p.cpus = 1
    end

    n.vm.network :private_network, ip: "192.168.10.20"
    n.vm.network "forwarded_port", guest: 4646, host: 5646
    n.vm.network "forwarded_port", guest: 80, host: 8080

    n.vm.provision "shell", inline: $setup
  end

  config.vm.define "wh-client1" do |n|
    n.vm.box = "wh-base"
    n.vm.hostname = "wh-client1"

    n.vm.provider "parallels" do |p|
      p.memory = 2048
      p.cpus = 1
    end

    n.vm.network :private_network, ip: "192.168.10.30"
    n.vm.network "forwarded_port", guest: 4646, host: 6646
    n.vm.network "forwarded_port", guest: 80, host: 9080

    n.vm.provision "shell", inline: $setup
  end

  config.vm.define "app-client1" do |n|
    n.vm.box = "app-base"
    n.vm.hostname = "app-client1"

    n.vm.provider "parallels" do |p|
      p.memory = 2048
      p.cpus = 1
    end

    n.vm.network :private_network, ip: "192.168.10.40"
    n.vm.network "forwarded_port", guest: 4646, host: 7646

    n.vm.provision "shell", inline: $setup
  end
end
