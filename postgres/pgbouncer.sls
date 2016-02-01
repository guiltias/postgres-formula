{% from "postgres/map.jinja" import postgres with context %}

include:
  - postgres.upstream

install-pgbouncer:
  pkg.latest:
    - pkgs:
      - pgbouncer
    - refresh: True
    - require:
      - pkgrepo: install-postgresql-repo


