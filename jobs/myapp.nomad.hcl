job "myapp" {
  datacenters = ["dc1"]
  type        = "service"

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

  group "myapp" {
    count = 1

    network {
      port "http" {}
    }

    task "deploy-myapp" {
      // resources {
      //   cpu    = 50
      //   memory = 128
      // }

      driver = "exec"

      service {
        name     = "myapp"
        port     = "http"
        provider = "nomad"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.http.rule=Host(`myapp.com`)",
        ]
      }

      env {
        APP_PORT = "${NOMAD_PORT_http}"
        APP_INSTANCE = "${NOMAD_ALLOC_INDEX}"
        APP_NAME = "myapp"
      }

      artifact {
        source = "git::https://github.com/gkspranger/nomad-fun"
        destination = "local/repo"

        options {
          ref = "simple"
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
