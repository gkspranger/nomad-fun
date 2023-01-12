job [[ .someapp.name | quote ]] {
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

  group "someapp" {
    count = [[ .someapp.count ]]

    network {
      port "http" {}
    }

    task "deploy-someapp" {
      driver = "exec"

      service {
        name     = [[ .someapp.name | quote ]]
        port     = "http"

        address = "192.168.50.30"

        tags = [
          "flask_app=true",
          [[ if .someapp.enable_routing ]]
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`${NOMAD_JOB_NAME}.example.com`)",
          [[ end ]]
        ]
      }

      env {
        APP_PORT = "${NOMAD_PORT_http}"
        APP_INSTANCE = "${NOMAD_ALLOC_INDEX}"
        APP_NAME = [[ .someapp.name | quote ]]
        APP_VERSION = [[ .someapp.version | quote ]]
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
