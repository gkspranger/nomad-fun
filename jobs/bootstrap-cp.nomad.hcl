job "bootstrap-cp" {
  datacenters = ["dc1"]
  type = "sysbatch"

  periodic {
    cron             = "* * * * * *"
    prohibit_overlap = true
  }

  constraint {
    attribute = "${meta.state}"
    value     = "bootstrapping"
  }

  constraint {
    attribute = "${meta.role}"
    value     = "cp"
  }

  constraint {
    attribute = "${meta.env}"
    value     = "dev"
  }

  group "bootstrap-cp" {
    task "install-ansible" {
      lifecycle {
        hook = "prestart"
        sidecar = false
      }

      driver = "raw_exec"

      config {
        command = "/usr/bin/bash"
        args    = [
          "-c",
          <<-EOF
          dnf install -y python3-devel
          python3 -m venv /opt/ansible/2-13-3
          /opt/ansible/2-13-3/bin/pip3 install ansible-core==2.13.3
          EOF
        ]
      }
    }

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
          -e "extravar_bootstrapping=true" \
          -e "extravar_env=${meta.env}" \
          -e "extravar_role=${meta.role}"
          EOF
        ]
      }
    }
  }
}
