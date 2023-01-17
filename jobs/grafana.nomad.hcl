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

    volume "grafana" {
      type      = "host"
      source    = "grafana"
      read_only = false
    }

    volume "grafana2" {
      type      = "host"
      source    = "grafana2"
      read_only = false
    }

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

      user = "22222:22222"

      volume_mount {
        volume      = "grafana2"
        destination = "/var/lib/grafana"
        read_only   = false
      }

      template {
        change_mode = "noop"
        destination = "local/datasource.yml"
        data = <<EOH
---
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    editable: false
    is_default: true
    access: proxy
    url: http://192.168.50.50:9090
EOH
      }


      config {
        image = "grafana/grafana-oss:9.3.2"
        network_mode = "host"

        volumes = [
          "local/datasource.yml:/etc/grafana/provisioning/datasources/default.yaml",
        ]

        ports = ["http"]
      }
    }
  }
}
