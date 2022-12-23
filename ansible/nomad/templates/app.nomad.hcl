data_dir  = "/opt/nomad/data"
bind_addr = "0.0.0.0"

log_level = "DEBUG"
log_file  = "/var/log/nomad.log"

advertise {
  http = "192.168.50.30"
  rpc  = "192.168.50.30"
  serf = "192.168.50.30"
}

client {
  enabled = true
  servers = ["192.168.50.10"]

  meta {
    role = "app"
    env = "dev"
    state = "ready"
  }
}

plugin "raw_exec" {
  config {
    enabled = true
  }
}

telemetry {
  collection_interval = "1s"
  disable_hostname = true
  prometheus_metrics = true
  publish_allocation_metrics = true
  publish_node_metrics = true
}
