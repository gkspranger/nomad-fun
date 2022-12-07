data_dir  = "/opt/nomad/data"
bind_addr = "0.0.0.0"

log_level = "DEBUG"
log_file  = "/var/log/nomad.log"

advertise {
  http = "192.168.50.40"
  rpc  = "192.168.50.40"
  serf = "192.168.50.40"
}

client {
  enabled = true
  servers = ["192.168.50.10"]

  meta {
    role = "javaapp"
    env = "dev"
    state = "bootstrapping"
  }
}

plugin "raw_exec" {
  config {
    enabled = true
  }
}
