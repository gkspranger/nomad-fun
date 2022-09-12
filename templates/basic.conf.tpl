upstream backend {
{{ range nomadService "hello-app" }}
  server {{ .Address }}:{{ .Port }};
{{ else }}server 127.0.0.1:65535; # force a 502
{{ end }}
}

server {
   listen 8080;
   location /app {
      proxy_pass http://backend;
   }
}
