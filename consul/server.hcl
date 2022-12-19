server = true
bootstrap_expect = 1
advertise_addr = "192.168.50.10"

data_dir = "/opt/consul"

log_file = "/var/log/consul/consul.log"
log_level = "debug"
log_rotate_max_files = 1

enable_syslog = false

enable_script_checks = true

addresses {
  http = "0.0.0.0"
  dns = "0.0.0.0"
}

ui_config {
  enabled = true
}
