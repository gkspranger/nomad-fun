job "nweb" {
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
    value     = "nweb"
  }

  constraint {
    attribute = "${meta.env}"
    value     = "dev"
  }

  group "nginx" {
    network {
      port "http" {
        static = 8080
      }
    }

    service {
      name = "nginx"
      port = "http"
      provider = "nomad"
    }

    task "nginx" {
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
        command = "/usr/sbin/nginx"
        args    = ["-e", "/dev/stderr"]
      }

      env {
        NWEB_ENV = "${meta.env}"
      }

      template {
        source        = "local/repo/templates/basic.conf.tpl"
        destination   = "/etc/nginx/conf.d/nweb.conf"
        change_mode   = "signal"
        change_signal = "SIGHUP"
      }
    }
  }
}
