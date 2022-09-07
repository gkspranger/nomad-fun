packer {
  required_plugins {
    vagrant = {
      version = ">= 1.0.2"
      source  = "github.com/hashicorp/vagrant"
    }
  }
}

source "vagrant" "rockylinux-8-nomad-server" {
  add_force    = true
  communicator = "ssh"
  provider     = "parallels"
  source_path  = "bento/rockylinux-8"
}

build {
  name = "rockylinux-8-nomad-server"
  sources = [
    "source.vagrant.rockylinux-8-nomad-server"
  ]

  provisioner "shell" {
    inline = [
      // "sudo yum clean all",
      // "sudo yum -y update",
      "sudo yum -y install python39-devel",
      "sudo python3 -m venv /opt/ansible",
      "sudo /opt/ansible/bin/pip3 install ansible-core==2.13.3",
    ]
  }

  provisioner "ansible-local" {
    playbook_dir            = "../ansible"
    playbook_file           = "../ansible/nomad_server.yml"
    command                 = "/opt/ansible/bin/ansible-playbook"
    clean_staging_directory = true
    extra_arguments = [
      "-i", "localhost,",
      "-e", "extravar_env=dev",
      "-e", "extravar_role=nomad_server",
      "-e", "extravar_bakingami=yes",
    ]
  }
}
