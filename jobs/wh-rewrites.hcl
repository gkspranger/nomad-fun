job "wh-rewrites" {
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
    value     = "wh"
  }

  constraint {
    attribute = "${meta.env}"
    value     = "dev"
  }

  group "wh-rewrites" {
    task "rewrite-node" {
      driver = "raw_exec"

      artifact {
        source = "git::https://github.com/gkspranger/nomad-fun"
        destination = "local/repo"

        options {
          ref = "main"
          depth = 1
        }
      }

      template {
        source        = "local/repo/templates/nownow.rewrites.conf.tpl"
        destination   = "local/nownow.rewrites.conf"
        change_mode = "script"
        change_script {
          command = "/usr/bin/bash"
          args    = [
            "-c",
            <<-EOF
            cmp --silent /etc/httpd/conf/nownow.rewrites.conf local/nownow.rewrites.conf
            if [[ "$?" == "1" ]]; then
              sudo mv -f local/nownow.rewrites.conf /etc/httpd/conf/nownow.rewrites.conf
              sudo systemctl reload httpd.service
            fi
            EOF
          ]
          timeout       = "5s"
          fail_on_error = false
        }
      }

      config {
        command = "/usr/bin/bash"
        args    = [
          "-c",
          <<-EOF
          sleep 1440
          EOF
        ]
      }
    }
  }
}
