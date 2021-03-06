{% from "postgres/map.jinja" import postgres with context %}

{% if postgres.use_upstream_repo %}
include:
  - postgres.upstream
{% endif %}

install-postgresql-client:
  pkg.installed:
    - name: {{ postgres.pkg_client }}
    - refresh: {{ postgres.use_upstream_repo }}

{% if postgres.pkg_libpq_dev %}
install-postgres-libpq-dev:
  pkg.installed:
    - name: {{ postgres.pkg_libpq_dev }}
{% endif %}

{% for username in salt['pillar.get']('users', []) -%}
/home/{{ username }}/.pgpass:
  file.managed:
    - user: {{ username }}
    - group: {{ username }}
    - mode: 600
    - source: salt://postgres/pgpass
    - template: jinja
{%- endfor %}
