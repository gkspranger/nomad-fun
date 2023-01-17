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

    volume "prometheus" {
      type      = "host"
      source    = "prometheus"
      read_only = false
    }

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

      address = "192.168.50.50"
    }

    task "deploy-prom" {
      driver = "docker"

      volume_mount {
        volume      = "prometheus"
        destination = "/prometheus"
        read_only   = false
      }

      template {
        change_mode = "noop"
        destination = "local/prometheus.yml"
        data = <<EOH
---
global:
  scrape_interval:     5s
  evaluation_interval: 5s

scrape_configs:
  - job_name: 'nomad_metrics'
    consul_sd_configs:
    - server: '192.168.50.10:8500'
      services:
      - 'nomad-client'
      - 'nomad'

    scrape_interval: 5s
    metrics_path: /v1/metrics
    params:
      format: ['prometheus']

  - job_name: 'prometheus'
    static_configs:
    - targets: ['127.0.0.1:9090']

    scrape_interval: 5s

  - job_name: 'flask_apps'
    consul_sd_configs:
    - server: '192.168.50.10:8500'
      tags:
      - 'flask_app=true'

    scrape_interval: 5s
    metrics_path: /metrics
EOH
      }

      config {
        image = "prom/prometheus:v2.40.7"
        network_mode = "host"

        volumes = [
          "local/prometheus.yml:/etc/prometheus/prometheus.yml",
        ]

        ports = ["http"]
      }
    }
  }
}
