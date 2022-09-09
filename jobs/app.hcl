job "helloworld" {
  datacenters = ["dc1"]

  meta {
    run_uuid = "${uuidv4()}"
  }

  constraint {
    attribute = "${meta.state}"
    value     = "ready"
  }

  constraint {
    attribute = "${meta.role}"
    value     = "app"
  }

  constraint {
    attribute = "${meta.env}"
    value     = "dev"
  }

  group "helloworld" {
    count = 3

    network {
      port "http" {}
    }

    task "helloworld" {
      resources {
        cpu    = 50
        memory = 128
      }

      driver = "exec"

      service {
        name     = "hello-app"
        port     = "http"
        provider = "nomad"

        check {
          type     = "http"
          name     = "hello_app_health"
          path     = "/healthz"
          interval = "10s"
          timeout  = "5s"

          check_restart {
            limit = 6
            grace = "60s"
          }
        }
      }

      env {
        APP_PORT = "${NOMAD_PORT_http}"
        APP_INSTANCE = "${NOMAD_ALLOC_INDEX}"
      }

      artifact {
        source = "git::https://github.com/gkspranger/nomad-fun"
        destination = "local/repo"

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
          set -eu
          cd ${NOMAD_TASK_DIR}/repo/app
          pip3 install -r requirements.txt
          python3 app.py
          EOF
        ]
      }
    }
  }
}
