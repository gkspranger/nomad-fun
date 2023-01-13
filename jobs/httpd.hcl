job "httpd" {
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

  group "httpd" {
    count = 3

    network {
      port "dhttp" {}
    }

    update {
      max_parallel      = 1
      health_check      = "checks"
      min_healthy_time  = "10s"
      healthy_deadline  = "5m"
      stagger           = "30s"
    }

    service {
      name = "httpd"
      port = "dhttp"

      address = "192.168.50.30"

      check {
        type     = "http"
        port     = "dhttp"
        path     = "/status.html"
        interval = "5s"
        timeout  = "2s"
        header {
          Host = ["secure.example.com"]
        }
      }

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.${NOMAD_JOB_NAME}.rule=Host(`secure.example.com`)",
      ]
    }

    task "httpd" {
      driver = "exec"

      artifact {
        source = "git::https://github.com/gkspranger/nomad-fun"
        destination = "local/repo"

        options {
          ref = "simple"
          depth = 1
        }
      }

      env {
        HTTPD_PORT = "${NOMAD_PORT_dhttp}"
        HTTPD_INDEX = "${NOMAD_ALLOC_INDEX}"
      }

      config {
        command = "/usr/bin/bash"
        args    = [
          "-c",
          <<-EOF
          set -eu
          mkdir -p /local/{root,api,secure}/cgi-bin
          mkdir -p /local/{root,api,secure}/html
          mkdir -p /local/logs
          mkdir -p /run/httpd
          echo "server available ${NOMAD_ALLOC_INDEX}" > /local/secure/html/status.html
          apachectl configtest
          /usr/sbin/httpd -f /etc/httpd/conf/httpd.conf -DFOREGROUND
          EOF
        ]
      }

      template {
        source        = "local/repo/templates/httpd.conf"
        destination   = "/etc/httpd/conf/httpd.conf"
      }

      template {
        source        = "local/repo/templates/security.rewrites.conf"
        destination   = "/etc/httpd/conf/security.rewrites.conf"
      }

      template {
        source        = "local/repo/templates/secure.example.com.rewrites.conf"
        destination   = "/etc/httpd/conf/secure.example.com.rewrites.conf"
      }

      template {
        source        = "local/repo/templates/secure.example.com.conf"
        destination   = "/etc/httpd/conf.d/000-secure.example.com.conf"
      }
    }
  }
}
