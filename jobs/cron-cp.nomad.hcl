job "cron-cp" {
  datacenters = ["dc1"]
  type = "sysbatch"

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
    value     = "cp"
  }

  constraint {
    attribute = "${meta.env}"
    value     = "dev"
  }

  group "cron-cp" {
    task "config-node" {
      driver = "raw_exec"

      artifact {
        source = "git::https://github.com/gkspranger/nomad-fun"
        destination = "local/repo"

        options {
          ref = "simple"
          depth = 1
        }
      }

      config {
        command = "/usr/bin/bash"
        args    = [
          "-c",
          <<-EOF
          cd ${NOMAD_TASK_DIR}/repo/ansible
          /opt/ansible/2-13-3/bin/ansible-playbook \
          -i localhost, \
          ${meta.role}.yml \
          -e "extravar_env=${meta.env}" \
          -e "extravar_role=${meta.role}"
          EOF
        ]
      }
    }
  }
}
