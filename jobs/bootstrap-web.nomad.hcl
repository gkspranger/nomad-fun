job "bootstrap-web" {
  datacenters = ["dc1"]
  type = "sysbatch"

  periodic {
    cron             = "* * * * * *"
    prohibit_overlap = true
  }

  constraint {
    attribute = "${meta.state}"
    value     = "bootstrapping"
  }

  constraint {
    attribute = "${meta.role}"
    value     = "web_server"
  }

  constraint {
    attribute = "${meta.env}"
    value     = "dev"
  }

  group "bootstrap-web" {
    task "install-ansible" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "raw_exec"

      config {
        command = "/usr/bin/bash"
        args    = [
          "-c",
          <<-EOF
          dnf install -y python3-devel
          python3 -m venv /opt/ansible/2-13-3
          /opt/ansible/2-13-3/bin/pip3 install ansible-core==2.13.3
          EOF
        ]
      }
    }
  }
}
