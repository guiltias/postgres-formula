{% from "postgres/map.jinja" import postgres with context %}
{% set local_ip = salt['grains.get']('local_interfaces')[0].values().0 %}

include:
  - postgres.upstream

install-pgbouncer:
  pkg.latest:
    - pkgs:
      - pgbouncer
    - refresh: True
    - require:
      - pkgrepo: install-postgresql-repo

{# TODO: set params tunable #}

configure-pgbouncer:
  file.managed:
    - name: /etc/pgbouncer/pgbouncer.ini
    - contents: |
      [databases]
      {% for base in postgres.database_list %}
      {{ base }} =
      {% endfor %}

      [pgbouncer]
      logfile = /var/log/postgresql/pgbouncer.log
      pidfile = /var/run/postgresql/pgbouncer.pid
      listen_addr = {{ local_ip }}
      listen_port = 6432
      unix_socket_dir = /var/run/postgresql
      auth_type = md5
      auth_file = /etc/pgbouncer/userlist.txt
      admin_users = postgres
      ; rails specific
      pool_mode = transaction
      server_reset_query =
      max_client_conn = 4000
      default_pool_size = 20
      reserve_pool_size = 0
      log_pooler_errors = 1
      ignore_startup_parameters = extra_float_digits
    - require:
      - pkg: install-pgbouncer
