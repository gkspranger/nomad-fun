// {{ config_managed }}

{% if nomad_is_server | default(False) %}
{{ lookup("template", "roles/nomad/templates/nomad_server.hcl") }}
{% else %}
{{ lookup("template", "roles/nomad/templates/nomad_client.hcl") }}
{% endif %}




