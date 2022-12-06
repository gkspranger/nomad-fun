data_dir  = "/opt/nomad/data"
bind_addr = "0.0.0.0"

log_level = "DEBUG"
log_file  = "/var/log/nomad.log"

server {
  enabled          = true
  bootstrap_expect = 1
}

client {
  enabled = true
  servers = ["192.168.50.10"]

  meta {
    role = "nomad_server"
    env = "ops"
  }
}

plugin "raw_exec" {
  config {
    enabled = true
  }
}
