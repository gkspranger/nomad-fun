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
      // provider = "nomad"
      port = "http"

      tags = [
        "traefik.enable=false",
      ]
    }

    task "deploy-lb" {
      driver = "docker"

      template {
        change_mode = "noop"
        destination = "local/traefik/wapp.yml"
        data = <<EOH
---
## Dynamic configuration
http:
  routers:
    router0:
      service: app_weighted
      rule: "Host(`wapp.example.com`)"
  services:
    app_weighted:
      weighted:
        services:
        - name: blueapp@consulcatalog
          weight: 3
        - name: greenapp@consulcatalog
          weight: 1
EOH
      }

      template {
        change_mode = "noop"
        destination = "local/traefik/wapp1.yml"
        data = <<EOH
---
## Dynamic configuration
http:
  routers:
    router1:
      service: app_weighted1
      rule: "Host(`wapp1.example.com`)"
  services:
    app_weighted1:
      weighted:
        services:
        - name: blueapp@consulcatalog
          weight: 3
        - name: greenapp@consulcatalog
          weight: 0
EOH
      }

      template {
        change_mode = "noop"
        destination = "local/traefik/future.yml"
        data = <<EOH
---
## Dynamic configuration
http:
  routers:
    router-future:
      service: greenapp@consulcatalog
      rule: "Host(`wapp.example.com`) && HeadersRegexp(`Cookie`, `future=.*`)"
EOH
      }

      config {
        image = "traefik:2.9"
        ports = ["admin", "http"]
        network_mode = "host"
        args = [
          "--api.dashboard=true",
          "--api.insecure=true",
          "--entrypoints.web.address=:${NOMAD_PORT_http}",
          "--entrypoints.traefik.address=:${NOMAD_PORT_admin}",
          "--providers.consulcatalog=true",
          "--providers.consulcatalog.exposedByDefault=false",
          "--providers.consulcatalog.endpoint.address=http://192.168.50.10:8500",
          "--providers.file.directory=local/traefik",
        ]
      }
    }
  }
}
