job "hweb" {
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
    value     = "hweb"
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
    }

    service {
      name = "httpd"
      port = "http"
      provider = "nomad"
    }

    task "httpd" {
      driver = "exec"

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
          mkdir -p /local/cgi-bin
          mkdir -p /local/html
          mkdir -p /local/logs
          apachectl configtest
          /usr/sbin/httpd -f /etc/httpd/conf/httpd.conf -DFOREGROUND
          EOF
        ]
      }

      template {
        data          = "server available"
        destination   = "/local/html/status.html"
        change_mode   = "noop"
      }

      template {
        source        = "local/repo/templates/httpd/httpd.conf"
        destination   = "/etc/httpd/confd/httpd.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      template {
        source        = "local/repo/templates/httpd/security.rewrites.conf"
        destination   = "/etc/httpd/confd/security.rewrites.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      template {
        source        = "local/repo/templates/httpd/hweb/bottom.rewrites.conf"
        destination   = "/etc/httpd/conf/bottom.rewrites.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }

      template {
        source        = "local/repo/templates/httpd/hweb/greggy.conf"
        destination   = "/etc/httpd/conf.d/greggy.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
    }
  }
}
