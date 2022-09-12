# env: {{ env "NWEB_ENV" }}
# role: {{ env "NWEB_ROLE" }}

{{ $env := env "NWEB_ENV" }}

{{ if eq $env "dev" }}
  {{ $suffix := "-d" }}
{{ else if eq $env "stage" }}
  {{ $suffix := "-s" }}
{{ else if eq $env "pi" }}
  {{ $suffix := "-pi" }}
{{ else if eq $env "prod" }}
  {{ $suffix := "" }}
{{ end }}


upstream backend {
{{ range nomadService "hello-app" }}
  server {{ .Address }}:{{ .Port }};
{{ else }}server 127.0.0.1:65535; # force a 502
{{ end }}
}

server {
   listen 8080;

  rewrite ^/rewrite{{ $suffix }}$ https://spranger.us last;

   location / {
      proxy_pass http://backend;
   }
}
