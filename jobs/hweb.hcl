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
        data = <<EOF
<VirtualHost *:10000>

ServerName greggy
ServerAlias greggy

DocumentRoot /local/html

<Directory "/local/html">
Options IncludesNoExec

Require all granted

AddDefaultCharset UTF-8
</Directory>

DirectoryIndex index.html

CustomLog /dev/stdout combinedio
ErrorLog /dev/stderr

</VirtualHost>
EOF

        destination   = "/etc/httpd/conf.d/hweb.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
    }
  }
}
