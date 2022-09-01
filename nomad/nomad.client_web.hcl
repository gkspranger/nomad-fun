log_level = "DEBUG"
log_file  = "/var/log/nomad.log"
data_dir  = "/opt/nomad"
bind_addr = "0.0.0.0"

plugin "raw_exec" {
  config {
    enabled = true
  }
}

client {
  enabled = true
  servers = ["192.168.10.10"]

  meta {
    state = "bootstrapping"
    role = "web"
  }
}
