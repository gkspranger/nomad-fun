data_dir  = "/opt/nomad/data"
bind_addr = "0.0.0.0"

log_level = "DEBUG"
log_file  = "/var/log/nomad.log"

advertise {
  http = "192.168.50.20"
  rpc  = "192.168.50.20"
  serf = "192.168.50.20"
}

client {
  enabled = true
  servers = ["192.168.50.10"]

  meta {
    role = "web_server"
    env = "dev"
  }
}

plugin "raw_exec" {
  config {
    enabled = true
  }
}
