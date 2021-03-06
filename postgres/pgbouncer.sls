
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
    - watch_in: 
      - service: run-pgbouncer


configure-pgbouncer-users:
  file.managed:
    - name: /etc/pgbouncer/userlist.txt
    - template: jinja
    - source: salt://postgres/userlist.txt
    - require:
      - pkg: install-pgbouncer
    - watch_in: 
      - service: run-pgbouncer

run-pgbouncer:
  service.running:
    - name: pgbouncer
    - enable: True
    - provider: service
    - full_restart: True
    - require:
      - file: configure-pgbouncer
      - pkg: install-pgbouncer
