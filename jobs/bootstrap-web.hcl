job "bootstrap-web" {
  datacenters = ["dc1"]
  type = "sysbatch"

  meta {
    run_uuid = "${uuidv4()}"
  }

  // periodic {
  //   cron             = "* * * * * *"
  //   prohibit_overlap = true
  // }

  constraint {
    attribute = "${meta.state}"
    value     = "bootstrapping"
  }

  constraint {
    attribute = "${meta.role}"
    value     = "web"
  }

  group "bootstrap-web" {
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
          pip3 install --user ansible-core==2.13.3
          EOF
        ]
      }
    }

    task "bootstrap-node" {
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
          which ansible-playbook
          ansible-playbook --version
          ansible-playbook -i 127.0.0.1, web.yml -e "extravar_env=dev"
          EOF
        ]
      }
    }
  }
}
