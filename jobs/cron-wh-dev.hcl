job "cron-wh-dev" {
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
    value     = "wh"
  }

  constraint {
    attribute = "${meta.env}"
    value     = "dev"
  }

  group "cron-wh-dev" {
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
          export PATH="/home/nomad/.local/bin:/home/nomad/bin:$PATH"
          cd ${NOMAD_TASK_DIR}/repo/ansible
          ansible-playbook \
          -i localhost, \
          wh.yml \
          -e "extravar_env=dev" \
          -e "extravar_role=wh"
          EOF
        ]
      }
    }
  }
}
