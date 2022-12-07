job "javaapp" {
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
    value     = "javaapp"
  }

  constraint {
    attribute = "${meta.env}"
    value     = "dev"
  }

  group "javaapp" {
    count = 1

    network {
      port "http" {}
    }

    task "deploy-javaapp" {
      // resources {
      //   cpu    = 50
      //   memory = 128
      // }

      driver = "java"

      service {
        name     = "javaapp"
        port     = "http"
        provider = "nomad"

        address = "192.168.50.40"

        tags = [
          "traefik.enable=true",
          "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`${NOMAD_JOB_NAME}.${meta.env}.example.com`)",
        ]
      }

      env {
        PORT = "${NOMAD_PORT_http}"
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
          jar_path    = "local/repo/javaapp/javaapp.jar"
          jvm_options = ["-Djava.net.preferIPv4Stack=true"]
      }
    }
  }
}
