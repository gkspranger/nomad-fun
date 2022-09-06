packer {
  required_plugins {
    vagrant = {
      version = ">= 1.0.2"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

source "vagrant" "rockylinux-8-ws" {
  add_force    = true
  communicator = "ssh"
  provider     = "parallels"
  source_path  = "bento/rockylinux-8"
}

build {
  name = "rockylinux-8-ws"
  sources = [
    "source.vagrant.rockylinux-8-ws"
  ]

  provisioner "shell" {
    inline = [
      // "sudo yum clean all",
      // "sudo yum -y update",
      "sudo yum -y install python39-devel",
      "sudo python3 -m venv /opt/ansible",
      // "sudo /opt/ansible/bin/activate && pip install ansible-core==2.13.3",
    ]
  }

  post-processors {
    post-processor "vagrant" {
      keep_input_artifact = true
      provider_override   = "parallels"
    }
  }
}
