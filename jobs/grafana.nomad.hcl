job "grafana" {
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
    value     = "cp"
  }

  constraint {
    attribute = "${meta.env}"
    value     = "dev"
  }

  group "grafana" {
    count = 1

    network {
      port  "http"{
         static = 3000
         to = 3000
      }
    }

    service {
      name = "grafana"
      // provider = "nomad"
      port = "http"

      address = "192.168.50.50"
    }

    task "deploy-grafana" {
      driver = "docker"

      config {
        image = "grafana/grafana-oss:9.3.2"

        ports = ["http"]
      }
    }
  }
}
