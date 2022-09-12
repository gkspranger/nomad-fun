job "cron-nweb-dev" {
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
    value     = "nweb"
  }

  constraint {
    attribute = "${meta.env}"
    value     = "dev"
  }

  group "cron-nweb-dev" {
    reschedule {
      attempts  = 0
      unlimited = false
    }

    task "config-node" {
      driver = "raw_exec"

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
          cd ${NOMAD_TASK_DIR}/repo/ansible
          /opt/ansible/bin/ansible-playbook \
          -i localhost, \
          nweb.yml \
          -e "extravar_env=dev" \
          -e "extravar_role=nweb"
          EOF
        ]
      }
    }
  }
}
