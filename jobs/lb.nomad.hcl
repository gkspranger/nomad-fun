job "lb" {
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
    value     = "lb"
  }

  constraint {
    attribute = "${meta.env}"
    value     = "dev"
  }

  group "lb" {
    count = 1

    network {
      port  "http"{
         static = 8080
         to = 8080
      }
      port  "admin"{
         static = 9080
         to = 9080
      }
    }

    service {
      name = "lb"
      provider = "nomad"
      port = "http"
    }

    task "deploy-lb" {
      driver = "docker"

      config {
        image = "traefik:2.9"
        ports = ["admin", "http"]
        args = [
          "--api.dashboard=true",
          "--api.insecure=true",
          "--entrypoints.web.address=:${NOMAD_PORT_http}",
          "--entrypoints.traefik.address=:${NOMAD_PORT_admin}",
          "--providers.nomad=true",
          "--providers.nomad.endpoint.address=http://192.168.50.10:4646",
        ]
      }
    }
  }
}
