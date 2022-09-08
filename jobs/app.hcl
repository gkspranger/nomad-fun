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
    count = 1

    network {
      port "http" {}
    }

    service {
      name     = "hello-app"
      port     = "http"
      provider = "nomad"
    }

    task "helloworld" {
      resources {
        cpu    = 50
        memory = 128
      }

      driver = "raw_exec"

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
          cd ${NOMAD_TASK_DIR}/repo/app
          python3 -m venv venv
          ./venv/bin/pip3 install -r requirements.txt
          ./venv/bin/python3 app.py
          EOF
        ]
      }

    }
  }
}
