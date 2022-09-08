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
      user = "app"

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
          whoami
          pwd
          ls -al
          EOF
        ]
      }
    }
  }
}
