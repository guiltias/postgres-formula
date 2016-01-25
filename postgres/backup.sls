{% from "postgres/map.jinja" import postgres with context %}

include:
  - postgres

/etc/wal-e.d/main/env:
  file.directory:
    - user: root
    - group: postgres
    - mode: 750
    - makedirs: True

/etc/wal-e.d/main/env/AWS_ACCESS_KEY_ID:
  file.managed:
    - user: root
    - group: postgres
    - mode: 650
    - contents:
      - {{ postgres.aws.access_key_id }}

/etc/wal-e.d/main/env/AWS_SECRET_ACCESS_KEY:
  file.managed:
    - user: root
    - group: postgres
    - mode: 650
    - contents:
      - {{ postgres.aws.secret_access_key }}

/etc/wal-e.d/main/env/WALE_S3_PREFIX:
  file.managed:
    - user: root
    - group: postgres
    - mode: 650
    - contents:
      - {{ postgres.aws.wale_s3_prefix }}

{% if postgres.init_replica == True %}
repostore-latest-postgres-backup:
  cmd.run:
    - name: rm -rf /var/lib/postgresql/9.2/main && envdir /etc/wal-e.d/main/env wal-e backup-fetch /var/lib/postgresql/9.2/main LATEST
    - cwd: /var/lib/postgresql
    - user: postgres
    - group: postgres
    - creates: /var/lib/postgresql/9.2/main/recovery.done 
    - require:
      - file: /etc/wal-e.d/main/env/WALE_S3_PREFIX
      - file: /etc/wal-e.d/main/env/AWS_SECRET_ACCESS_KEY
      - file: /etc/wal-e.d/main/env/AWS_ACCESS_KEY_ID
      - pkg: install-postgresql
      - pip: install-wal-e 

set-postgresql-dir-permissions:
  file.directory:
    - name: /var/lib/postgresql/9.2/main
    - user: postgres
    - group: postgres
    - mode: 700
    - require:
      - cmd: repostore-latest-postgres-backup

configure-restore-script:
  file.managed:
    - name: /var/lib/postgresql/9.2/main/recovery.conf
    - user: postgres
    - group: postgres
    - mode: 655
    - contents:
      - standby_mode = 'on'
      - primary_conninfo = 'host={{ postgres.replica_master_host }}'
      - restore_command = 'envdir /etc/wal-e.d/main/env /usr/local/bin/wal-e wal-fetch %f %p' 
    - require:
      - cmd: repostore-latest-postgres-backup
      - file: set-postgresql-dir-permissions
    
run-postgresql:
  service.running:
    - enable: true
    - name: {{ postgres.service }}
    - require:
      - pkg: install-postgresql
      - cmd: repostore-latest-postgres-backup
      - file: configure-restore-script
      - file: set-postgresql-dir-permissions
{% endif %}
