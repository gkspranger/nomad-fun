// {{ config_managed }}

{% if nomad_is_server | default(False) %}
{{ lookup("ansible.builtin.template", "roles/resource/nomad/templates/nomad_server.hcl") }}
{% else %}
{{ lookup("ansible.builtin.template", "roles/resource/nomad/templates/nomad_client.hcl") }}
{% endif %}
