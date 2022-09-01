job "web" {
  datacenters = ["dc1"]
  type = "system"

  meta {
    run_uuid = "${uuidv4()}"
  }

  constraint {
    attribute = "${meta.state}"
    value     = "ready"
  }

  constraint {
    attribute = "${meta.role}"
    value     = "web"
  }

  constraint {
    attribute = "${meta.env}"
    value     = "dev"
  }

  group "web" {
    network {
      port "http" {
        static = 8080
      }
    }

    service {
      name = "${meta.role}-${meta.env}"
      port = "http"
      provider = "nomad"
    }

    task "nginx" {
      driver = "exec"

      config {
        command = "/usr/bin/bash"
        args    = [
          "-c",
          <<-EOF
          echo "hello world"
          sleep 120
          EOF
        ]
      }
    }
  }
}
