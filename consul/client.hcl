server = false

data_dir = "/opt/consul"

log_file = "/var/log/consul/consul.log"
log_level = "debug"
log_rotate_max_files = 1

enable_syslog = false

enable_script_checks = true

retry_join = [
  "192.168.50.10",
]
