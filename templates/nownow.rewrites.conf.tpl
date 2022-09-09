ProxyHCExpr ok200 {%{REQUEST_STATUS} =~ /^200/}

<Proxy balancer://hello-app>
{{ range nomadService "hello-app" }}
  BalancerMember http://{{ .Address }}:{{ .Port }} hcmethod=GET hcexpr=ok200 hcuri=/healthz hcinterval=5 hcpasses=2 hcfails=6
{{ else }}
  BalancerMember http://localhost:65535
{{ end }}

ProxyPass /app balancer://hello-app
ProxyPassReverse /app balancer://hello-app
