[[- define "job_name" -]]
[[- if eq .blueapp.job_name "" -]]
[[- .nomad_pack.pack.name | quote -]]
[[- else -]]
[[- .blueapp.job_name | quote -]]
[[- end -]]
[[- end -]]
