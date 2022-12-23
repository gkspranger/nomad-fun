job "prom" {
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

  group "prom" {
    count = 1

    network {
      port  "http"{
         static = 9090
         to = 9090
      }
    }

    service {
      name = "prom"
      // provider = "nomad"
      port = "http"
    }

    task "deploy-prom" {
      driver = "docker"

      config {
        image = "prom/prometheus:v2.40.7"
        ports = ["http"]
      }
    }
  }
}
