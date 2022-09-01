job "web-cron" {
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
    value     = "web"
  }

  constraint {
    attribute = "${meta.env}"
    value     = "dev"
  }

  group "web-cron" {
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
          export PATH="/root/.local/bin:/root/bin:$PATH"
          cd ${NOMAD_TASK_DIR}/repo/ansible
          which ansible-playbook
          ansible-playbook --version
          ansible-playbook \
          -i localhost, \
          web.yml \
          -e "extravar_env=dev" \
          -e "extravar_role=web"
          EOF
        ]
      }
    }
  }
}