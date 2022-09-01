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
    value     = "web"
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
          pip3 install --user ansible-core==2.13.3
          EOF
        ]
      }
    }

    task "bootstrap-node" {
      driver = "raw_exec"

      artifact {
        source = "git::https://github.com/gkspranger/nomad-fun"
        destination = "local/nomad-fun"

        options {
          ref = "main"
          depth = 1
        }
      }

      config {
        command = "/usr/bin/bash"
        args    = [
          "-c",
          <<-EOF
          echo "hello world"
          EOF
        ]
      }
    }
  }
}
