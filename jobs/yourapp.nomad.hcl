job "yourapp" {
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

  group "yourapp" {
    count = 1

    network {
      port "http" {}
    }

    task "deploy-yourapp" {
      // resources {
      //   cpu    = 50
      //   memory = 128
      // }

      driver = "exec"

      service {
        name     = "yourapp"
        port     = "http"
        provider = "nomad"

        address = "192.168.50.30"

        tags = [
          "traefik.enable=false",
          "traefik.http.routers.http.rule=Host(`${NOMAD_JOB_NAME}.${meta.env}.example.com`)",
        ]
      }

      env {
        APP_PORT = "${NOMAD_PORT_http}"
        APP_INSTANCE = "${NOMAD_ALLOC_INDEX}"
        APP_NAME = "yourapp"
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
