job "cron-app-dev" {
  datacenters = ["dc1"]
  type = "sysbatch"

  meta {
    run_uuid = "${uuidv4()}"
  }

  periodic {
    cron             = "*/5 * * * * *"
    prohibit_overlap = true
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

  group "cron-app-dev" {
    task "config-node" {
      driver = "raw_exec"
      user = "nomad"

      artifact {
        source = "git::https://github.com/gkspranger/nomad-fun"
        destination = "local/varrepo"

        options {
          ref = "main"
          depth = 1
        }
      }

      artifact {
        source = "git::https://github.com/gkspranger/nomad-fun"
        destination = "local/repo"

        options {
          ref = "main"
          depth = 1
        }
      }

      env {
        DEFAULT_LOCAL_TMP = "/home/nomad/.ansible/tmp/"
        ANSIBLE_LOCAL_TMP = "/home/nomad/.ansible/tmp/"
      }

      config {
        command = "/usr/bin/bash"
        args    = [
          "-c",
          <<-EOF
          cd ${NOMAD_TASK_DIR}/repo/ansible
          cp ${NOMAD_TASK_DIR}/varrepo/external/ps_vars.yml tmp/.
          /opt/ansible/bin/ansible-playbook \
          -i localhost, \
          app.yml \
          -e "extravar_env=dev" \
          -e "extravar_role=app"
          EOF
        ]
      }
    }
  }
}
