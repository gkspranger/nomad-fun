job "httpd" {
  datacenters = ["dc1"]
  type = "system"

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
    network {
      port "http" {
        static = 10000
      }
      port "dhttp" {}
    }

    service {
      name = "httpd"
      port = "http"
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
      }

      config {
        command = "/usr/bin/bash"
        args    = [
          "-c",
          <<-EOF
          set -eu
          mkdir -p /local/cgi-bin
          mkdir -p /local/html
          mkdir -p /local/logs
          mkdir -p /run/httpd
          apachectl configtest
          /usr/sbin/httpd -f /etc/httpd/conf/httpd.conf -DFOREGROUND
          EOF
        ]
      }

      template {
        data          = "server available"
        destination   = "/local/html/status.html"
      }

      template {
        source        = "local/repo/templates/httpd.conf"
        destination   = "/etc/httpd/conf/httpd.conf"
      }

      template {
        source        = "local/repo/templates/security.rewrites.conf"
        destination   = "/etc/httpd/conf/security.rewrites.conf"
      }
    }
  }
}
