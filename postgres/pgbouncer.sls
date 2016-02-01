
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
    - template: jinja
    - source: salt://postgres/pgbouncer.ini
    - require:
      - pkg: install-pgbouncer
