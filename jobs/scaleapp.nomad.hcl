job "scaleapp" {
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

  group "scaleapp" {
    count = 1

    network {
      port "http" {}
    }

    scaling {
      enabled = true
      min     = 1
      max     = 5

      policy {
        cooldown = "1m"

        check "req_per_min" {
          source = "prometheus"
          query  = <<EOH
          floor(
            sum(increase(flask_http_request_total[1m]))
            /
            count(flask_exporter_info)
          )
          EOH

          strategy "target-value" {
            target = 50
          }
        }
      }
    }

    task "deploy-scaleapp" {
      driver = "exec"

      service {
        name     = "scaleapp"
        port     = "http"

        address = "192.168.50.30"

        tags = [
          "flask_app=true",
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`${NOMAD_JOB_NAME}.example.com`)",
        ]
      }

      env {
        APP_PORT = "${NOMAD_PORT_http}"
        APP_INSTANCE = "${NOMAD_ALLOC_INDEX}"
        APP_NAME = "scaleapp"
        APP_VERSION = "0.2"
      }

      artifact {
        source = "git::https://github.com/gkspranger/nomad-fun"
        destination = "local/repo"

        options {
          ref = "simple"
          depth = 1
        }
      }

      template {
        data        = <<EOH
{{ range ls "apps/dev/scaleapp" }}
{{ .Key | toUpper }}={{ .Value }}
{{ end }}
        EOH
        destination = "local/env"
        env         = true
        change_mode = "restart"
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
